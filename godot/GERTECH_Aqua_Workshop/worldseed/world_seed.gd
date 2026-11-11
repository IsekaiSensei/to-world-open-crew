class_name WorldSeed
extends Resource

const CURRENT_VERSION := "1.0"
const SAVE_PATH := "user://gertech_worldseed_v1.json"
const STARTER_STOCK := {"ore": 120, "salvage": 56, "pure_component": 16, "soil": 0, "food": 0, "labor_token": 0, "packed_block": 0, "stabilized_frame": 0, "forged_blank": 0, "alloy": 0, "scrap": 0, "defense_tech": 0}
@export var version: String = CURRENT_VERSION
@export var realm_id: String = "gertech_aqua_world"
@export var vertices: Dictionary = {}
@export var edges: Dictionary = {}
@export var assemblies: Dictionary = {}
@export var tetras: Dictionary = {}
@export var inventory: Dictionary = {}
@export var equipment: Dictionary = {"visor_chip_capacity": 1}
@export var event_log: Array[SeedWorldEvent] = []
@export var next_ids: Dictionary = {"vertex": 1, "edge": 1, "assembly": 1, "tetra": 1, "event": 1}
@export var foundry_runs: int = 0

func _init() -> void:
	inventory = STARTER_STOCK.duplicate(true)

func _new_id(category: String, prefix: String) -> String:
	var n := int(next_ids.get(category, 1))
	next_ids[category] = n + 1
	return "%s_%d" % [prefix, n]

func log_event(kind: String, actor: String, payload: Dictionary) -> void:
	var ev := SeedWorldEvent.new()
	ev.id = int(next_ids.get("event", 1))
	next_ids["event"] = ev.id + 1
	ev.timestamp = Time.get_unix_time_from_system()
	ev.kind = kind
	ev.actor = actor
	ev.payload = payload.duplicate(true)
	event_log.append(ev)
	changed.emit()

func _position_taken(p: Vector3) -> bool:
	for v in vertices.values():
		if (v as SeedVertex).position.distance_squared_to(p) < 0.000001:
			return true
	return false

func add_vertex(p: Vector3, module_type: String = "empty", occupied: bool = false, actor: String = "worldseed") -> String:
	if _position_taken(p): return ""
	var v := SeedVertex.new()
	v.id = _new_id("vertex", "v")
	v.position = p
	v.module_type = module_type
	v.occupied = occupied
	vertices[v.id] = v
	log_event("add_vertex", actor, {"vertex": v.to_data()})
	return v.id

func find_edge(a: String, b: String) -> String:
	for k in edges:
		var e: SeedEdge = edges[k]
		if (e.from_vertex == a and e.to_vertex == b) or (e.from_vertex == b and e.to_vertex == a): return str(k)
	return ""

func add_edge(a: String, b: String, joint: String = "structural", actor: String = "worldseed", assembly_id: String = "") -> String:
	if a == b or not vertices.has(a) or not vertices.has(b): return ""
	var old := find_edge(a, b)
	if old != "": return old
	var e := SeedEdge.new()
	e.id = _new_id("edge", "e")
	e.from_vertex = a
	e.to_vertex = b
	e.joint_type = joint
	e.assembly_id = assembly_id
	edges[e.id] = e
	log_event("link_edge", actor, {"edge": e.to_data()})
	return e.id

func add_tetra(ids: Array[String], actor: String = "delaunay3d", assembly_id: String = "") -> String:
	if ids.size() != 4: return ""
	var unique := {}
	for id in ids:
		if unique.has(id) or not vertices.has(id): return ""
		unique[id] = true
	var a: Vector3 = vertices[ids[0]].position
	var b: Vector3 = vertices[ids[1]].position
	var c: Vector3 = vertices[ids[2]].position
	var d: Vector3 = vertices[ids[3]].position
	if absf((b - a).dot((c - a).cross(d - a))) < 0.00001: return ""
	var sorted_ids := ids.duplicate()
	sorted_ids.sort()
	for tet in tetras.values():
		var old_ids: Array[String] = (tet as SeedTetrahedron).vertices.duplicate()
		old_ids.sort()
		if sorted_ids == old_ids: return ""
	var t := SeedTetrahedron.new()
	t.id = _new_id("tetra", "t")
	t.vertices = ids.duplicate()
	t.assembly_id = assembly_id
	tetras[t.id] = t
	log_event("add_tetra", actor, {"tetra": t.to_data()})
	return t.id

func create_assembly(kind: String, root_id: String, ids: Array[String], parent: String = "", actor: String = "worldseed") -> String:
	if not vertices.has(root_id): return ""
	var a := SeedAssembly.new()
	a.id = _new_id("assembly", "a")
	a.kind = kind
	a.root_vertex = root_id
	a.parent_assembly = parent if assemblies.has(parent) else ""
	for id in ids:
		if vertices.has(id):
			a.vertex_ids.append(id)
			vertices[id].assembly_id = a.id
	for e in edges.values():
		if e.from_vertex in a.vertex_ids and e.to_vertex in a.vertex_ids:
			a.edge_ids.append(e.id)
	assemblies[a.id] = a
	if assemblies.has(a.parent_assembly): assemblies[a.parent_assembly].child_assemblies.append(a.id)
	log_event("create_assembly", actor, {"assembly": a.to_data()})
	return a.id

func amount(name: String) -> int:
	return max(0, int(inventory.get(name, 0)))

func can_consume(goods: Dictionary) -> bool:
	for key in goods:
		if not inventory.has(str(key)) or int(goods[key]) < 0 or amount(str(key)) < int(goods[key]): return false
	return true

func apply_material_receipt(result: Dictionary) -> bool:
	var consumed: Dictionary = result.get("materials_consumed", {})
	var produced: Dictionary = result.get("materials_produced", {})
	if not can_consume(consumed): return false
	for key in produced:
		if not inventory.has(str(key)) or int(produced[key]) < 0: return false
	for key in consumed: inventory[str(key)] = amount(str(key)) - int(consumed[key])
	for key in produced: inventory[str(key)] = amount(str(key)) + int(produced[key])
	foundry_runs += 1
	log_event("minigame_receipt", str(result.get("station", "minigame")), {"consumed": consumed.duplicate(true), "produced": produced.duplicate(true), "score": int(result.get("score", 0)), "stats": result.get("stats", {}).duplicate(true)})
	return true

func occupy_vertex(id: String, module_type: String, actor: String = "workshop", charge_inventory: bool = true) -> bool:
	if not vertices.has(id): return false
	var v: SeedVertex = vertices[id]
	if v.occupied or module_type == "empty": return false
	if charge_inventory and amount(module_type) <= 0: return false
	if charge_inventory: inventory[module_type] = amount(module_type) - 1
	v.occupied = true
	v.module_type = module_type
	log_event("place_module", actor, {"vertex_id": id, "module_type": module_type, "inventory_consumed": 1 if charge_inventory else 0})
	return true

func free_vertex(id: String, actor: String = "repair") -> bool:
	if not vertices.has(id): return false
	var v: SeedVertex = vertices[id]
	if not v.occupied or v.module_type == "core": return false
	var recovered := v.module_type
	v.module_type = "empty"
	v.occupied = false
	inventory[recovered] = amount(recovered) + 1
	log_event("recover_module", actor, {"vertex_id": id, "material": recovered})
	return true

func populate_scaffold(material: String, maximum: int, actor: String = "foundry_placer") -> int:
	var candidates := vertices.keys()
	candidates.sort()
	var placed := 0
	for id in candidates:
		if placed >= maximum or amount(material) <= 0: break
		if occupy_vertex(str(id), material, actor, true): placed += 1
	return placed

func scaffold_origin() -> String:
	if vertices.is_empty(): return add_vertex(Vector3.ZERO, "core", true, "fairy_spawn")
	for id in vertices:
		if (vertices[id] as SeedVertex).module_type == "core": return str(id)
	return str(vertices.keys()[0])

func to_data() -> Dictionary:
	var vs: Dictionary = {}
	var es: Dictionary = {}
	var ass: Dictionary = {}
	var ts: Dictionary = {}
	for k in vertices: vs[k] = vertices[k].to_data()
	for k in edges: es[k] = edges[k].to_data()
	for k in assemblies: ass[k] = assemblies[k].to_data()
	for k in tetras: ts[k] = tetras[k].to_data()
	var evs: Array = []
	for ev in event_log: evs.append(ev.to_data())
	return {"version": CURRENT_VERSION, "realm_id": realm_id, "vertices": vs, "edges": es, "assemblies": ass, "tetras": ts, "inventory": inventory.duplicate(true), "equipment": equipment.duplicate(true), "event_log": evs, "next_ids": next_ids.duplicate(true), "foundry_runs": foundry_runs}

func load_data(d: Dictionary) -> void:
	version = str(d.get("version", CURRENT_VERSION))
	realm_id = str(d.get("realm_id", "gertech_aqua_world"))
	vertices.clear()
	edges.clear()
	assemblies.clear()
	tetras.clear()
	event_log.clear()
	for k in d.get("vertices", {}): vertices[k] = SeedVertex.from_data(d["vertices"][k])
	for k in d.get("edges", {}): edges[k] = SeedEdge.from_data(d["edges"][k])
	for k in d.get("assemblies", {}): assemblies[k] = SeedAssembly.from_data(d["assemblies"][k])
	for k in d.get("tetras", {}): tetras[k] = SeedTetrahedron.from_data(d["tetras"][k])
	for item in d.get("event_log", []): event_log.append(SeedWorldEvent.from_data(item))
	inventory = STARTER_STOCK.duplicate(true)
	for key in inventory: inventory[key] = max(0, int(d.get("inventory", {}).get(key, inventory[key])))
	equipment = d.get("equipment", {"visor_chip_capacity": 1}).duplicate(true)
	next_ids = {"vertex": 1, "edge": 1, "assembly": 1, "tetra": 1, "event": 1}
	for key in next_ids: next_ids[key] = max(1, int(d.get("next_ids", {}).get(key, 1)))
	foundry_runs = max(0, int(d.get("foundry_runs", 0)))
	changed.emit()

# Workshop-only explicit reset. Preserves resource identity and signal listeners.
# Fixed architecture and minigame code are intentionally outside this ledger.
func reset_to_empty_starter_stock() -> void:
    vertices.clear()
    edges.clear()
    assemblies.clear()
    tetras.clear()
    event_log.clear()
    inventory = STARTER_STOCK.duplicate(true)
    equipment = {"visor_chip_capacity": 1}
    next_ids = {"vertex": 1, "edge": 1, "assembly": 1, "tetra": 1, "event": 1}
    foundry_runs = 0
    changed.emit()

func save_to_disk() -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(to_data(), "  "))
	file.close()
	return true

func load_from_disk() -> bool:
	if not FileAccess.file_exists(SAVE_PATH): return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null: return false
	var result = JSON.parse_string(file.get_as_text())
	file.close()
	if not result is Dictionary: return false
	load_data(result)
	return true

func summary() -> String:
	return "WORLD SEED: %d VERTICES  /  %d GOLD JOINTS  /  %d CELLS  /  %d EVENTS" % [vertices.size(), edges.size(), tetras.size(), event_log.size()]
