class_name SilhouetteTetraMesher
extends RefCounted

# GERTECH: silhouette -> conforming voxel tetrahedral cells -> WorldSeed graph.
# Input is a normalized 2D outline OR an alpha-masked PNG. This is a 2.5D
# EXTRUSION of the silhouette, not a reconstruction of unknown photo depth.
# Unlike unconstrained Delaunay on a concave point cloud, every tetra here lies
# entirely inside an accepted voxel. Six conforming tetras exactly fill each
# accepted voxel, and neighboring voxels agree on every shared face diagonal.
# All durable mutations use WorldSeed methods (never renderer state).

const CORNERS: Array[Vector3i] = [
	Vector3i(0, 0, 0), Vector3i(1, 0, 0),
	Vector3i(0, 1, 0), Vector3i(1, 1, 0),
	Vector3i(0, 0, 1), Vector3i(1, 0, 1),
	Vector3i(0, 1, 1), Vector3i(1, 1, 1)
]
# Six tetrahedra meet along body diagonal (0 -> 7).
# This is a face-conforming split on a uniform 3D grid.
const SIX_TETRAS: Array[Vector4i] = [
	Vector4i(0, 1, 3, 7), Vector4i(0, 3, 2, 7),
	Vector4i(0, 2, 6, 7), Vector4i(0, 6, 4, 7),
	Vector4i(0, 4, 5, 7), Vector4i(0, 5, 1, 7)
]
const TETRA_PAIRS := [[0, 1], [0, 2], [0, 3], [1, 2], [1, 3], [2, 3]]

func _failed(message: String) -> Dictionary:
	push_warning("GERTECH SILHOUETTE: " + message)
	return {"ok": false, "error": message, "assembly_id": "", "vertices": [], "edges": [], "tetras": []}

## The outline is a PackedVector2Array in NORMALIZED [0..1] coordinates.
## Its Y axis points up. Builds a one-to-several-voxel-thick 3D object.
## options: columns (9), rows (6), layers (2), cell_size (0.75),
## origin (Vector3.ZERO), max_voxels (96), material ("packed_block"),
## place_from_inventory (0), source_id (reference ID, not a new canon name).
func build_from_outline(seed: WorldSeed, outline: PackedVector2Array, kind: String = "subassembly", options: Dictionary = {}) -> Dictionary:
	if outline.size() < 3:
		return _failed("An outline needs at least three points.")
	var cols := clampi(int(options.get("columns", 9)), 2, 36)
	var rows := clampi(int(options.get("rows", 6)), 2, 36)
	var cells: Array[Vector2i] = []
	for y in range(rows):
		for x in range(cols):
			var uv := Vector2((float(x) + 0.5) / float(cols), (float(y) + 0.5) / float(rows))
			if Geometry2D.is_point_in_polygon(uv, outline):
				cells.append(Vector2i(x, y))
	return _build_voxels(seed, cells, cols, rows, kind, options, "outline")

## For an image with transparent background, alpha determines the silhouette.
## "corner_color" is an optional approximate segmentation for SIMPLE flat
## backgrounds (not a replacement for a clean mask for complicated photos).
func build_from_image(seed: WorldSeed, image_path: String, kind: String = "subassembly", options: Dictionary = {}) -> Dictionary:
	var image := Image.new()
	var texture = load(image_path) if image_path.begins_with("res://") else null
	if texture is Texture2D:
		image = texture.get_image()
	elif image.load(image_path) != OK:
		return _failed("Cannot open source image: " + image_path)
	if image == null or image.is_empty():
		return _failed("The source image contains no pixels.")
	var mode: String = str(options.get("mask_mode", "alpha"))
	if mode == "alpha" and image.detect_alpha() == Image.ALPHA_NONE:
		return _failed("Source has no transparency; supply a cutout PNG or use mask_mode='corner_color' for a simple background.")
	if mode != "alpha" and mode != "corner_color":
		return _failed("mask_mode must be alpha or corner_color.")
	var max_dim := clampi(int(options.get("max_dimension", 12)), 3, 36)
	var aspect := float(image.get_width()) / maxf(1.0, float(image.get_height()))
	var cols := max_dim if aspect >= 1.0 else maxi(2, int(round(float(max_dim) * aspect)))
	var rows := max_dim if aspect < 1.0 else maxi(2, int(round(float(max_dim) / aspect)))
	var threshold := clampf(float(options.get("alpha_threshold", 0.45)), 0.05, 0.95)
	var background := image.get_pixel(0, 0)
	var tolerance := clampf(float(options.get("background_tolerance", 0.15)), 0.01, 1.0)
	var cells: Array[Vector2i] = []
	for y in range(rows):
		for x in range(cols):
			var px := clampi(int((float(x) + 0.5) / float(cols) * image.get_width()), 0, image.get_width() - 1)
			var py := clampi(int((1.0 - (float(y) + 0.5) / float(rows)) * image.get_height()), 0, image.get_height() - 1)
			var pixel := image.get_pixel(px, py)
			var inside := pixel.a >= threshold
			if mode == "corner_color":
				var diff := Vector3(pixel.r - background.r, pixel.g - background.g, pixel.b - background.b).length()
				inside = diff >= tolerance
			if inside:
				cells.append(Vector2i(x, y))
	var safe_options := options.duplicate(true)
	safe_options["source_id"] = str(options.get("source_id", image_path))
	return _build_voxels(seed, cells, cols, rows, kind, safe_options, "image_mask")

func _connected_islands(cells: Array[Vector2i]) -> int:
	var members: Dictionary = {}
	for c in cells:
		members[c] = true
	var visited: Dictionary = {}
	var islands := 0
	for c in cells:
		if visited.has(c):
			continue
		islands += 1
		var queue: Array[Vector2i] = [c]
		visited[c] = true
		var head := 0
		while head < queue.size():
			var current: Vector2i = queue[head]
			head += 1
			for direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var neighbor: Vector2i = current + direction
				if members.has(neighbor) and not visited.has(neighbor):
					visited[neighbor] = true
					queue.append(neighbor)
	return islands

func _grid_point(origin: Vector3, x: int, y: int, z: int, cols: int, rows: int, size: float, layers: int) -> Vector3:
	return origin + Vector3((float(x) - float(cols) * 0.5) * size, (float(y) - float(rows) * 0.5) * size, (float(z) - float(layers) * 0.5) * size)

func _build_voxels(seed: WorldSeed, cells: Array[Vector2i], cols: int, rows: int, kind: String, options: Dictionary, source_mode: String) -> Dictionary:
	if seed == null:
		return _failed("WorldSeed is required.")
	if cells.is_empty():
		return _failed("The silhouette contains no visible cells at this resolution.")
	if _connected_islands(cells) != 1:
		return _failed("Silhouette has separated islands. Provide one connected part, or build the separated parts as child assemblies.")
	var layers := clampi(int(options.get("layers", 2)), 1, 5)
	var max_voxels := clampi(int(options.get("max_voxels", 96)), 1, 300)
	if cells.size() * layers > max_voxels:
		return _failed("Volume exceeds max_voxels (%d). Decrease the image resolution or depth." % max_voxels)
	var size := clampf(float(options.get("cell_size", 0.75)), 0.12, 4.0)
	var origin: Vector3 = options.get("origin", Vector3.ZERO)
	var actor := "silhouette_tetra_mesher"
	var needed: Dictionary = {}
	var voxels: Array[Vector3i] = []
	for cell in cells:
		for layer in range(layers):
			var base := Vector3i(cell.x, cell.y, layer)
			voxels.append(base)
			for offset in CORNERS:
				needed[base + offset] = true
	# Preflight against other assemblies' existing occupied positions so a
	# source cannot overwrite another object or half-build on failure.
	var positions: Dictionary = {}
	for original_id in seed.vertices:
		var old: SeedVertex = seed.vertices[original_id]
		positions[old.position.snapped(Vector3.ONE * 0.0001)] = str(original_id)
	for point in needed:
		var p: Vector3 = _grid_point(origin, point.x, point.y, point.z, cols, rows, size, layers)
		if positions.has(p.snapped(Vector3.ONE * 0.0001)):
			return _failed("A WorldSeed vertex already occupies part of this volume. Pick an unoccupied origin.")
	var corners_to_id: Dictionary = {}
	var new_vertices: Array[String] = []
	var corner_coords: Array = needed.keys()
	corner_coords.sort_custom(func(a: Vector3i, b: Vector3i) -> bool:
		if a.z != b.z: return a.z < b.z
		if a.y != b.y: return a.y < b.y
		return a.x < b.x)
	for point in corner_coords:
		var p: Vector3 = _grid_point(origin, point.x, point.y, point.z, cols, rows, size, layers)
		var id := seed.add_vertex(p, "empty", false, actor)
		if id.is_empty():
			return _failed("Vertex creation failed after preflight; review this incomplete attempt before retrying.")
		corners_to_id[point] = id
		new_vertices.append(id)
	# Create the assembly BEFORE its tetras/joints so each subsequently logged
	# cell and joint carries the correct persistent assembly_id from birth.
	var root := new_vertices[0]
	var center := _grid_point(origin, cols / 2, rows / 2, layers / 2, cols, rows, size, layers)
	var best_dist := INF
	for id in new_vertices:
		var distance: float = (seed.vertices[id] as SeedVertex).position.distance_squared_to(center)
		if distance < best_dist:
			best_dist = distance
			root = id
	var assembly_id := seed.create_assembly(kind, root, new_vertices, "", actor)
	if assembly_id.is_empty():
		return _failed("Could not create assembly; voxels may require inspection.")
	var edge_lookup: Dictionary = {}
	var new_edges: Array[String] = []
	var new_tetras: Array[String] = []
	for base in voxels:
		var local: Array[String] = []
		for offset in CORNERS:
			local.append(str(corners_to_id[base + offset]))
		for split in SIX_TETRAS:
			var quad: Array[String] = [local[split.x], local[split.y], local[split.z], local[split.w]]
			var tid := seed.add_tetra(quad, actor, assembly_id)
			if not tid.is_empty():
				new_tetras.append(tid)
			for pair in TETRA_PAIRS:
				var a: String = quad[pair[0]]
				var b: String = quad[pair[1]]
				var key := a + "|" + b if a < b else b + "|" + a
				if edge_lookup.has(key):
					continue
				edge_lookup[key] = true
				var eid := seed.add_edge(a, b, "structural", actor, assembly_id)
				if not eid.is_empty():
					new_edges.append(eid)
	var assembly: SeedAssembly = seed.assemblies[assembly_id]
	assembly.edge_ids = new_edges.duplicate()
	# No module material is created for free. Only occupancy charges the SAME
	# WorldSeed inventory used by the Tetris foundry.
	var material: String = str(options.get("material", "packed_block"))
	var maximum_to_place := maxi(0, int(options.get("place_from_inventory", 0)))
	var placed := 0
	for id in new_vertices:
		if placed >= maximum_to_place or seed.amount(material) <= 0:
			break
		if seed.occupy_vertex(id, material, actor, true):
			placed += 1
	seed.log_event("silhouette_tetra_commit", actor, {
		"assembly_id": assembly_id, "source_mode": source_mode,
		"source_id": str(options.get("source_id", "")),
		"voxels": voxels.size(), "vertices": new_vertices.size(),
		"edges": new_edges.size(), "tetras": new_tetras.size(),
		"edge_ids": new_edges.duplicate(), "tetra_ids": new_tetras.duplicate(),
		"material_placed_from_inventory": placed
	})
	return {"ok": true, "assembly_id": assembly_id, "vertices": new_vertices,
		"edges": new_edges, "tetras": new_tetras, "voxels": voxels.size(),
		"placed_from_inventory": placed, "source_mode": source_mode}
