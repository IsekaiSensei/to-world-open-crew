class_name DelaunayEdges
extends RefCounted

# Planar XZ Delaunay: does not destroy earlier physical assembly joints.
func triangulate(seed: WorldSeed, ids: Array[String], plane_y: float = 0.0, tolerance: float = 0.1) -> Array[String]:
	var points := PackedVector2Array()
	var labels: Array[String] = []
	var seen_positions: Dictionary = {}
	for id in ids:
		if not seed.vertices.has(id): continue
		var v: SeedVertex = seed.vertices[id]
		if absf(v.position.y - plane_y) > tolerance: continue
		var uv := Vector2(v.position.x, v.position.z)
		if seen_positions.has(uv): continue
		seen_positions[uv] = true
		labels.append(id)
		points.append(uv)
	var new_ids: Array[String] = []
	if points.size() < 3: return new_ids
	var triangle_indices := Geometry2D.triangulate_delaunay(points)
	for i in range(0, triangle_indices.size(), 3):
		for pair in [[0, 1], [1, 2], [2, 0]]:
			var a: String = labels[triangle_indices[i + pair[0]]]
			var b: String = labels[triangle_indices[i + pair[1]]]
			if seed.find_edge(a, b) != "": continue
			var eid := seed.add_edge(a, b, "structural", "delaunay_2d")
			if not eid.is_empty(): new_ids.append(eid)
	return new_ids
