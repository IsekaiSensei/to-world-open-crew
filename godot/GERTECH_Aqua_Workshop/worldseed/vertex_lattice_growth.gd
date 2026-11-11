class_name VertexLatticeGrowth
extends RefCounted

const OFFSETS: Array[Vector3] = [
	Vector3(1, 0, 0), Vector3(-1, 0, 0),
	Vector3(0, 1, 0), Vector3(0, -1, 0),
	Vector3(0, 0, 1), Vector3(0, 0, -1),
	Vector3(1, 1, 0), Vector3(1, -1, 0),
	Vector3(1, 0, 1), Vector3(1, 0, -1),
	Vector3(0, 1, 1), Vector3(0, 1, -1)
]
var seed: WorldSeed
var rng := RandomNumberGenerator.new()

func setup(world_seed: WorldSeed, random_seed: int = 42) -> void:
	seed = world_seed
	rng.seed = random_seed

func grow(start_vertex_id: String, target_count: int, max_radius: float = 6.0) -> Array[String]:
	var created: Array[String] = []
	if seed == null or not seed.vertices.has(start_vertex_id): return created
	var origin: Vector3 = seed.vertices[start_vertex_id].position
	var frontier: Array[String] = []
	for vid in seed.vertices: frontier.append(str(vid))
	var positions: Dictionary = {}
	for v in seed.vertices.values(): positions[(v as SeedVertex).position] = true
	while created.size() < target_count and not frontier.is_empty():
		var idx := rng.randi_range(0, frontier.size() - 1)
		var source_id: String = frontier[idx]
		var source: SeedVertex = seed.vertices[source_id]
		var candidate: Array[Vector3] = []
		var weights: Array[float] = []
		var sum := 0.0
		for offset in OFFSETS:
			var pos: Vector3 = source.position + offset
			if pos.distance_to(origin) > max_radius: continue
			if positions.has(pos): continue
			var neighbors := 0
			for check in OFFSETS:
				if positions.has(pos + check): neighbors += 1
			if neighbors == 0: continue
			candidate.append(pos)
			var weight := float(neighbors)
			weights.append(weight)
			sum += weight
		if candidate.is_empty():
			frontier.remove_at(idx)
			continue
		var pick := rng.randf() * sum
		var choice: Vector3 = candidate.back()
		for c in range(candidate.size()):
			pick -= weights[c]
			if pick <= 0.0:
				choice = candidate[c]
				break
		var id := seed.add_vertex(choice, "empty", false, "fairy_lattice_growth")
		if id.is_empty(): continue
		seed.add_edge(source_id, id, "structural", "fairy_lattice_growth")
		positions[choice] = true
		frontier.append(id)
		created.append(id)
	return created
