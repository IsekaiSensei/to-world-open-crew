class_name SeedEdge
extends Resource

@export var id: String = ""
@export var from_vertex: String = ""
@export var to_vertex: String = ""
@export var joint_type: String = "structural"
@export var assembly_id: String = ""
@export var constraints: Dictionary = {}

func to_data() -> Dictionary:
	return {"id": id, "from": from_vertex, "to": to_vertex, "joint_type": joint_type, "assembly_id": assembly_id, "constraints": constraints.duplicate(true)}

static func from_data(d: Dictionary) -> SeedEdge:
	var e := SeedEdge.new()
	e.id = str(d.get("id", ""))
	e.from_vertex = str(d.get("from", ""))
	e.to_vertex = str(d.get("to", ""))
	e.joint_type = str(d.get("joint_type", "structural"))
	e.assembly_id = str(d.get("assembly_id", ""))
	e.constraints = d.get("constraints", {}).duplicate(true)
	return e
