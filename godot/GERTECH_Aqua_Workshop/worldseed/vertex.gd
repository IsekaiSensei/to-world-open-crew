class_name SeedVertex
extends Resource

@export var id: String = ""
@export var position: Vector3 = Vector3.ZERO
@export var module_type: String = "empty"
@export var material_id: String = ""
@export var occupied: bool = false
@export var assembly_id: String = ""
@export var socket_state: Dictionary = {}
@export var metadata: Dictionary = {}

func to_data() -> Dictionary:
	return {"id": id, "position": [position.x, position.y, position.z], "module_type": module_type, "material_id": material_id, "occupied": occupied, "assembly_id": assembly_id, "socket_state": socket_state.duplicate(true), "metadata": metadata.duplicate(true)}

static func from_data(d: Dictionary) -> SeedVertex:
	var v := SeedVertex.new()
	v.id = str(d.get("id", ""))
	var p: Array = d.get("position", [0.0, 0.0, 0.0])
	if p.size() == 3:
		v.position = Vector3(float(p[0]), float(p[1]), float(p[2]))
	v.module_type = str(d.get("module_type", "empty"))
	v.material_id = str(d.get("material_id", ""))
	v.occupied = bool(d.get("occupied", false))
	v.assembly_id = str(d.get("assembly_id", ""))
	v.socket_state = d.get("socket_state", {}).duplicate(true)
	v.metadata = d.get("metadata", {}).duplicate(true)
	return v
