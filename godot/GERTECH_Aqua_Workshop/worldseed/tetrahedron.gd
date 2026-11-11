class_name SeedTetrahedron
extends Resource

@export var id: String = ""
@export var vertices: Array[String] = []
@export var assembly_id: String = ""
@export var material_hint: String = "empty"

func to_data() -> Dictionary:
	return {"id": id, "vertices": vertices.duplicate(), "assembly_id": assembly_id, "material_hint": material_hint}

static func from_data(d: Dictionary) -> SeedTetrahedron:
	var t := SeedTetrahedron.new()
	t.id = str(d.get("id", ""))
	for v in d.get("vertices", []): t.vertices.append(str(v))
	t.assembly_id = str(d.get("assembly_id", ""))
	t.material_hint = str(d.get("material_hint", "empty"))
	return t
