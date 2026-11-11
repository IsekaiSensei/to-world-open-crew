class_name WorldSeedRenderer
extends Node3D

# View-only adapter. The WorldSeed Resource owns the graph, materials and
# event log. This node never creates/removes vertices, edges or tetras.
var seed: WorldSeed
var show_tetra_surfaces: bool = false
var _queued: bool = false
var _cube_model: PackedScene
var _simple_cube: BoxMesh
var _tiny_socket: BoxMesh
var _gold_material: StandardMaterial3D
var _skins_material: StandardMaterial3D
var _material_cache: Dictionary = {}
const ORIGINAL_CUBE := "res://assets/gertech_cube/parts/cube_1m.glb"
const MAX_SOURCE_GLBS := 3  # source cube GLB contains many sub-nodes; avoid hundreds of drawcalls
const MAX_VISIBLE_TETRA_FACES := 1500
const VisualKit = preload("res://graphics/gertech_visual_kit.gd")
const DECORATED_NODE_LIMIT := 220
var detailed_kit_enabled := true

func _ready() -> void:
	_simple_cube = BoxMesh.new()
	_simple_cube.size = Vector3.ONE * 0.47
	_tiny_socket = BoxMesh.new()
	_tiny_socket.size = Vector3.ONE * 0.17
	_gold_material = _make_material(Color("e6ba54"), 0.9, 0.03)
	_skins_material = _make_material(Color(0.24, 0.73, 0.89, 0.11), 0.15, 0.03)
	_skins_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if ResourceLoader.exists(ORIGINAL_CUBE):
		var source = load(ORIGINAL_CUBE)
		if source is PackedScene:
			_cube_model = source

func setup(world_seed: WorldSeed) -> void:
	if seed != null and seed.changed.is_connected(_schedule_refresh):
		seed.changed.disconnect(_schedule_refresh)
	seed = world_seed
	if seed != null:
		seed.changed.connect(_schedule_refresh)
	_schedule_refresh()

func _make_material(color: Color, metalness: float = 0.0, emission: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metalness
	material.roughness = 0.26
	if color.a < 0.999:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	if emission > 0.0:
		material.emission_enabled = true
		material.emission = Color(color.r, color.g, color.b)
		material.emission_energy_multiplier = emission
	return material

func _module_material(module_type: String) -> Material:
	if _material_cache.has(module_type):
		return _material_cache[module_type]
	var color := Color(0.47, 0.84, 0.98, 0.26)
	match module_type:
		"core": color = Color(0.96, 0.74, 0.29, 0.95)
		"packed_block": color = Color(0.49, 0.49, 0.92, 0.86)
		"forged_blank": color = Color(0.77, 0.82, 0.91, 0.86)
		"alloy": color = Color(0.89, 0.54, 0.92, 0.86)
		"ore": color = Color(0.68, 0.45, 0.31, 0.85)
		"salvage": color = Color(0.33, 0.77, 0.62, 0.85)
		"pure_component": color = Color(0.56, 0.91, 0.98, 0.88)
		_: pass
	var material := _make_material(color, 0.22, 0.17 if module_type != "empty" else 0.02)
	_material_cache[module_type] = material
	return material

func _schedule_refresh() -> void:
	if _queued or not is_inside_tree():
		return
	_queued = true
	call_deferred("_redraw")

func _batched_boxes(parent: Node3D, tag: String, transforms: Array, mat: Material) -> void:
	if transforms.is_empty():
		return
	var box := BoxMesh.new()
	box.size = Vector3.ONE
	var many := MultiMesh.new()
	many.transform_format = MultiMesh.TRANSFORM_3D
	many.mesh = box
	many.instance_count = transforms.size()
	for i in range(transforms.size()):
		many.set_instance_transform(i, transforms[i])
	var draw := MultiMeshInstance3D.new()
	draw.name = tag
	draw.multimesh = many
	draw.material_override = mat
	parent.add_child(draw)

func _scaled_box(center: Vector3, size: Vector3) -> Transform3D:
	return Transform3D(Basis().scaled(size), center)

func _redraw() -> void:
	_queued = false
	if not is_inside_tree() or seed == null:
		return
	for child in get_children():
		child.free()
	var structural := Node3D.new()
	structural.name = "REAL_WORLDSEED_LINKS_ONLY"
	add_child(structural)
	var modules := Node3D.new()
	modules.name = "MODULE_VISUALS_FROM_STORED_VERTICES"
	add_child(modules)
	var glass_boxes: Array[Transform3D] = []
	var cosmic_boxes: Array[Transform3D] = []
	var gold_trim: Array[Transform3D] = []
	var gold_caps: Array[Transform3D] = []
	var empty_socket: Array[Transform3D] = []
	var fallback: Dictionary = {}
	var detailed_count := 0
	var side := 0.49
	var half := side * 0.5
	# These render-only brackets never add an edge to WorldSeed. Each
	# actual structural edge remains in the separate real-link batch below.
	for id in seed.vertices:
		var v: SeedVertex = seed.vertices[id]
		if not v.occupied:
			empty_socket.append(_scaled_box(v.position, Vector3.ONE * 0.15))
			continue
		if not detailed_kit_enabled or detailed_count >= DECORATED_NODE_LIMIT:
			var type_name := str(v.module_type)
			if not fallback.has(type_name):
				fallback[type_name] = []
			(fallback[type_name] as Array).append(_scaled_box(v.position, Vector3.ONE * 0.40))
			continue
		detailed_count += 1
		glass_boxes.append(_scaled_box(v.position, Vector3.ONE * side))
		cosmic_boxes.append(_scaled_box(v.position, Vector3.ONE * side * 0.83))
		for axis in range(3):
			for a in [-1.0, 1.0]:
				for b in [-1.0, 1.0]:
					var center := v.position
					var size := Vector3.ONE * side * 0.049
					size[axis] = side * 1.015
					center[(axis + 1) % 3] += a * half
					center[(axis + 2) % 3] += b * half
					gold_trim.append(_scaled_box(center, size))
		for x in [-1.0, 1.0]:
			for y in [-1.0, 1.0]:
				for z in [-1.0, 1.0]:
					gold_caps.append(_scaled_box(v.position + Vector3(x, y, z) * half, Vector3.ONE * side * 0.14))
	_batched_boxes(modules, "Galaxy_Interiors_From_Modules", cosmic_boxes, VisualKit.galaxy())
	_batched_boxes(modules, "Crystal_Housings_From_Modules", glass_boxes, VisualKit.glass())
	_batched_boxes(modules, "Decorative_Edge_Housings_Not_Connections", gold_trim, VisualKit.gold())
	_batched_boxes(modules, "Machined_Gold_Corner_Fittings", gold_caps, VisualKit.gold())
	_batched_boxes(modules, "Unoccupied_Vertex_Sockets", empty_socket, _gold_material)
	for type_name in fallback:
		_batched_boxes(modules, "Far_LOD_" + str(type_name), fallback[type_name], _module_material(str(type_name)))
	# Only saved graph edges are drawn as true structural gold connections.
	var joint_transforms: Array[Transform3D] = []
	for id in seed.edges:
		var edge: SeedEdge = seed.edges[id]
		if not seed.vertices.has(edge.from_vertex) or not seed.vertices.has(edge.to_vertex):
			continue
		var a: Vector3 = seed.vertices[edge.from_vertex].position
		var b: Vector3 = seed.vertices[edge.to_vertex].position
		var delta := b - a
		var span := delta.length()
		if span < 0.00001:
			continue
		var aligned := Basis(Quaternion(Vector3.UP, delta.normalized())).scaled(Vector3(1.0, span, 1.0))
		joint_transforms.append(Transform3D(aligned, (a + b) * 0.5))
	if not joint_transforms.is_empty():
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.033
		mesh.bottom_radius = 0.033
		mesh.height = 1.0
		mesh.radial_segments = 8
		var many := MultiMesh.new()
		many.transform_format = MultiMesh.TRANSFORM_3D
		many.mesh = mesh
		many.instance_count = joint_transforms.size()
		for idx in range(joint_transforms.size()):
			many.set_instance_transform(idx, joint_transforms[idx])
		var batch := MultiMeshInstance3D.new()
		batch.name = "SAVED_GOLD_CONNECTIONS_BATCH"
		batch.multimesh = many
		batch.material_override = _gold_material
		structural.add_child(batch)
	if show_tetra_surfaces:
		_draw_volume_faces()

func _face_key(a: String, b: String, c: String) -> String:
	var names := [a, b, c]
	names.sort()
	return "%s|%s|%s" % [names[0], names[1], names[2]]

func _draw_volume_faces() -> void:
	# A face used by TWO tetras is interior and never shown. Thus only the
	# actual exterior of the stored volume is drawn, not every interior face.
	var faces: Dictionary = {}
	for tet in seed.tetras.values():
		var names: Array[String] = tet.vertices
		if names.size() != 4:
			continue
		for inds in [[0, 1, 2], [0, 1, 3], [0, 2, 3], [1, 2, 3]]:
			var a: String = names[inds[0]]
			var b: String = names[inds[1]]
			var c: String = names[inds[2]]
			var key := _face_key(a, b, c)
			if faces.has(key):
				faces[key]["count"] = int(faces[key]["count"]) + 1
			else:
				faces[key] = {"names": [a, b, c], "count": 1}
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var triangles := 0
	for datum in faces.values():
		if int(datum["count"]) != 1:
			continue
		var names: Array = datum["names"]
		if not seed.vertices.has(names[0]) or not seed.vertices.has(names[1]) or not seed.vertices.has(names[2]):
			continue
		for id in names:
			surface.add_vertex(seed.vertices[id].position)
		triangles += 1
		if triangles >= MAX_VISIBLE_TETRA_FACES:
			break
	if triangles == 0:
		return
	surface.generate_normals()
	var render := MeshInstance3D.new()
	render.name = "TETRA_BOUNDARY_ONLY"
	render.mesh = surface.commit()
	render.material_override = _skins_material
	add_child(render)
