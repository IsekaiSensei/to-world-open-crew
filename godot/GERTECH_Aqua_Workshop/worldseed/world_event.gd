class_name SeedWorldEvent
extends Resource

@export var id: int = 0
@export var timestamp: float = 0.0
@export var kind: String = ""
@export var actor: String = ""
@export var payload: Dictionary = {}

func to_data() -> Dictionary:
	return {"id": id, "timestamp": timestamp, "kind": kind, "actor": actor, "payload": payload.duplicate(true)}

static func from_data(d: Dictionary) -> SeedWorldEvent:
	var e := SeedWorldEvent.new()
	e.id = int(d.get("id", 0))
	e.timestamp = float(d.get("timestamp", 0.0))
	e.kind = str(d.get("kind", ""))
	e.actor = str(d.get("actor", ""))
	e.payload = d.get("payload", {}).duplicate(true)
	return e
