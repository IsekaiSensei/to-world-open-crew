extends Node
class_name WorkshopInventory

# Single authority: WorldSeed.inventory. This node is only the old workshop's API.
signal inventory_changed
const LEGACY_SAVE_PATH := "user://gertech_workshop.cfg"
var seed: WorldSeed
var last_receipt: Dictionary = {}

func _ready() -> void:
	seed = WorldSeed.new()
	if not seed.load_from_disk():
		_import_legacy_inventory()
		# Empty construction graph is intentional. Press G to create a scaffold.
		seed.save_to_disk()
	seed.changed.connect(_on_seed_changed)

func _all_vertex_ids() -> Array[String]:
	var ids: Array[String] = []
	for id in seed.vertices: ids.append(str(id))
	return ids

func _import_legacy_inventory() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(LEGACY_SAVE_PATH) != OK: return
	var stored: Dictionary = cfg.get_value("workshop", "stacks", {})
	for k in seed.inventory:
		if stored.has(k): seed.inventory[k] = max(0, int(stored[k]))
	seed.equipment = cfg.get_value("workshop", "equipment", {"visor_chip_capacity": 1}).duplicate(true)
	seed.foundry_runs = max(0, int(cfg.get_value("workshop", "foundry_runs", 0)))
	seed.log_event("import_legacy_ledger", "workshop", {"source": "gertech_workshop.cfg"})

func _on_seed_changed() -> void:
	inventory_changed.emit()

func amount(material: String) -> int:
	return seed.amount(material)

func can_consume(materials: Dictionary) -> bool:
	return seed.can_consume(materials)

func get_foundry_config() -> Dictionary:
	return {"name": "TETRIS / FORGE FOUNDRY", "inputs": {"ore": amount("ore"), "salvage": amount("salvage"), "pure_component": amount("pure_component")}, "enable_alloy": amount("pure_component") >= 4, "target_lines": 8, "gravity_seconds": 0.62}

func deposit_from_minigame(result: Dictionary) -> bool:
	if not seed.apply_material_receipt(result): return false
	last_receipt = result.duplicate(true)
	seed.save_to_disk()
	return true

func make_mouse_visor_chip_upgrade() -> bool:
	var cost := {"packed_block": 4, "forged_blank": 1}
	if not seed.can_consume(cost): return false
	for material in cost: seed.inventory[material] = seed.amount(material) - cost[material]
	seed.equipment["visor_chip_capacity"] = int(seed.equipment.get("visor_chip_capacity", 1)) + 1
	seed.log_event("build_equipment", "workshop", {"item": "visor_chip_capacity", "cost": cost})
	seed.save_to_disk()
	return true

func mouse_maze_config() -> Dictionary:
	return {"chip_charges": int(seed.equipment.get("visor_chip_capacity", 1))}

func summary() -> String:
	return "ORE %d  |  SALVAGE %d  |  PURE %d  |  PACKED %d  |  BLANKS %d  |  SCRAP %d  |  VISOR CHIPS %d" % [amount("ore"), amount("salvage"), amount("pure_component"), amount("packed_block"), amount("forged_blank"), amount("scrap"), int(seed.equipment.get("visor_chip_capacity", 1))]

# Reset through the game, not the operating system's file browser.
# Keep one backup of the former persistent JSON for recovery.
func reset_workshop_to_empty() -> bool:
	if seed == null:
		return false
	if FileAccess.file_exists(WorldSeed.SAVE_PATH):
		var old_save := FileAccess.open(WorldSeed.SAVE_PATH, FileAccess.READ)
		if old_save != null:
			var previous_json := old_save.get_as_text()
			old_save.close()
			var backup := FileAccess.open("user://gertech_worldseed_before_reset.json", FileAccess.WRITE)
			if backup != null:
				backup.store_string(previous_json)
				backup.close()
	seed.reset_to_empty_starter_stock()
	last_receipt.clear()
	var saved := seed.save_to_disk()
	inventory_changed.emit()
	return saved
