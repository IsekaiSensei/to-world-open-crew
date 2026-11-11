class_name Delaunay3D
extends RefCounted

# Incremental 3D Bowyer-Watson with a super-tetra, circumsphere tests,
# cavity boundary-face extraction, and deterministic micro-perturbations.
# Intended for dozens/low hundreds of points PER ASSEMBLY, not an entire realm.
const EPS := 0.00000001

func tetrahedralize(seed: WorldSeed, selected: Array[String], store_tetras: bool = true) -> Dictionary:
	var result := {"edges": [], "tetras": [], "points": 0}
	var ids: Array[String] = []
	var points: Array[Vector3] = []
	var unique: Dictionary = {}
	for vid in selected:
		if not seed.vertices.has(vid): continue
		var p: Vector3 = seed.vertices[vid].position
		if unique.has(p): continue
		unique[p] = true
		ids.append(vid)
		points.append(p)
	result["points"] = points.size()
	if points.size() < 4: return result
	var raw: Array = _bowyer_watson_3d(points)
	for quad in raw:
		var names: Array[String] = [ids[quad[0]], ids[quad[1]], ids[quad[2]], ids[quad[3]]]
		if store_tetras:
			var tid := seed.add_tetra(names, "delaunay_3d")
			if not tid.is_empty(): result["tetras"].append(tid)
		for pair in [[0, 1], [0, 2], [0, 3], [1, 2], [1, 3], [2, 3]]:
			var a: String = names[pair[0]]
			var b: String = names[pair[1]]
			if seed.find_edge(a, b) != "": continue
			var eid := seed.add_edge(a, b, "structural", "delaunay_3d")
			if not eid.is_empty(): result["edges"].append(eid)
	return result

func _face_key(f: Array) -> String:
	var indices := f.duplicate()
	indices.sort()
	return "%d|%d|%d" % [indices[0], indices[1], indices[2]]

func _circumsphere(a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> Dictionary:
	var ab := b - a
	var ac := c - a
	var ad := d - a
	var det := ab.dot(ac.cross(ad))
	if absf(det) < EPS: return {}
	var rhs := Vector3((b.length_squared() - a.length_squared()) * 0.5, (c.length_squared() - a.length_squared()) * 0.5, (d.length_squared() - a.length_squared()) * 0.5)
	var center := (ac.cross(ad) * rhs.x + ad.cross(ab) * rhs.y + ab.cross(ac) * rhs.z) / det
	return {"center": center, "radius_squared": center.distance_squared_to(a)}

func _bowyer_watson_3d(src: Array[Vector3]) -> Array:
	var n := src.size()
	var lo := src[0]
	var hi := src[0]
	for p in src:
		lo = lo.min(p)
		hi = hi.max(p)
	var middle := (lo + hi) * 0.5
	var r := maxf(1.0, (hi - lo).length() * 20.0)
	var points := src.duplicate()
	# Deterministic symbolic perturbation for lattice/cospherical data. The
	# rendered vertex coordinates are NOT changed. Original zero-volume
	# tetrahedra are rejected by WorldSeed.add_tetra().
	for i in range(n):
		var q: Vector3 = points[i]
		var j := float(i + 1)
		points[i] = q + Vector3(sin(j * 13.13), cos(j * 17.17), sin(j * 31.31)) * 0.00008
	points.append(middle + Vector3(0, 3.0 * r, 0))
	points.append(middle + Vector3(2.0 * r, -r, 2.0 * r))
	points.append(middle + Vector3(-2.0 * r, -r, 2.0 * r))
	points.append(middle + Vector3(0, -r, -3.0 * r))
	var tetras: Array = [[n, n + 1, n + 2, n + 3]]
	for point_idx in range(n):
		var bad: Dictionary = {}
		var boundary: Dictionary = {}
		for ti in range(tetras.size()):
			var tet: Array = tetras[ti]
			var sphere := _circumsphere(points[tet[0]], points[tet[1]], points[tet[2]], points[tet[3]])
			if sphere.is_empty(): continue
			var dist: float = points[point_idx].distance_squared_to(sphere["center"])
			if dist > float(sphere["radius_squared"]) + maxf(EPS, float(sphere["radius_squared"]) * 0.000000001): continue
			bad[ti] = true
			var faces := [[tet[0], tet[1], tet[2]], [tet[0], tet[1], tet[3]], [tet[0], tet[2], tet[3]], [tet[1], tet[2], tet[3]]]
			for f in faces:
				var key := _face_key(f)
				if boundary.has(key):
					boundary[key]["count"] = int(boundary[key]["count"]) + 1
				else:
					boundary[key] = {"face": f, "count": 1}
		if bad.is_empty(): continue
		var keep: Array = []
		for ti in range(tetras.size()):
			if not bad.has(ti): keep.append(tetras[ti])
		tetras = keep
		for entry in boundary.values():
			if int(entry["count"]) != 1: continue
			var face: Array = entry["face"]
			var new_tet: Array = [face[0], face[1], face[2], point_idx]
			var va: Vector3 = points[new_tet[0]]
			var vb: Vector3 = points[new_tet[1]]
			var vc: Vector3 = points[new_tet[2]]
			var vd: Vector3 = points[new_tet[3]]
			if absf((vb - va).dot((vc - va).cross(vd - va))) > EPS:
				tetras.append(new_tet)
	var final: Array = []
	for tet in tetras:
		var valid := true
		for idx in tet:
			if idx >= n: valid = false
		if valid: final.append(tet)
	return final
