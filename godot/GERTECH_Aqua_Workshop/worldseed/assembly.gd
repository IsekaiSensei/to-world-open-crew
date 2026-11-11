class_name SeedAssembly
extends Resource

@export var id: String = ""
@export var root_vertex: String = ""
@export var kind: String = "subassembly"
@export var vertex_ids: Array[String] = []
@export var edge_ids: Array[String] = []
@export var child_assemblies: Array[String] = []
@export var parent_assembly: String = ""
@export var persistent: bool = true

func to_data() -> Dictionary:
	return {"id": id, "root_vertex": root_vertex, "kind": kind, "vertex_ids": vertex_ids.duplicate(), "edge_ids": edge_ids.duplicate(), "child_assemblies": child_assemblies.duplicate(), "parent_assembly": parent_assembly, "persistent": persistent}

static func from_data(d: Dictionary) -> SeedAssembly:
	var a := SeedAssembly.new()
	a.id = str(d.get("id", ""))
	a.root_vertex = str(d.get("root_vertex", ""))
	a.kind = str(d.get("kind", "subassembly"))
	for x in d.get("vertex_ids", []): a.vertex_ids.append(str(x))
	for x in d.get("edge_ids", []): a.edge_ids.append(str(x))
	for x in d.get("child_assemblies", []): a.child_assemblies.append(str(x))
	a.parent_assembly = str(d.get("parent_assembly", ""))
	a.persistent = bool(d.get("persistent", true))
	return a
