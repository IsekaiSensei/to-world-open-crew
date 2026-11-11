extends "res://core/game_loop/minigame_interface.gd"

# Foundry theme sits OUTSIDE core. The host supplies materials and listens for results.
const GridScript = preload("res://core/tetris/tetromino_grid.gd")
const CellSkin = preload("res://graphics/foundry_cell_skin.gd")
const ConsoleSkin = preload("res://graphics/foundry_console_skin.gd")
const PIECE_NAMES := ["I", "O", "T", "L", "J", "S", "Z"]
const COLORS := {
	"ore": Color("dfa55e"),
	"salvage": Color("6dc6df"),
	"pure_component": Color("f4e4b2")
}
var grid: TetrominoGrid
var active_shape := ""
var active_pos := Vector2i(4, 0)
var active_rotation := 0
var active_materials: Array = []
var next_shape := ""
var held_shape := ""
var can_hold := true
var hold_used := false
var alloy_enabled := false
var input_budget: Dictionary = {}
var material_spent: Dictionary = {"ore": 0, "salvage": 0, "pure_component": 0}
var material_produced: Dictionary = {"packed_block": 0, "stabilized_frame": 0, "forged_blank": 0, "scrap": 0}
var lines_cleared := 0
var tetrises := 0
var pieces_locked := 0
var target_lines := 8
var score := 0
var heat := 0.19
var gravity_timer := 0.0
var elapsed := 0.0
var finished := false
var status := "FEED STOCK ACCEPTED"
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	set_process_unhandled_input(true)

func start(config_override: Dictionary = {}) -> void:
	super.start(config_override)
	input_budget = config.get("inputs", {}).duplicate(true)
	alloy_enabled = bool(config.get("enable_alloy", false))
	target_lines = max(1, int(config.get("target_lines", 8)))
	grid = GridScript.new()
	active_shape = ""
	next_shape = _random_shape()
	_spawn_piece()
	queue_redraw()

func get_score() -> int:
	return score

func _random_shape() -> String:
	return PIECE_NAMES[rng.randi_range(0, PIECE_NAMES.size() - 1)]

func _choose_materials() -> Array:
	var choices: Array = []
	for kind in ["ore", "salvage"]:
		if int(input_budget.get(kind, 0)) - int(material_spent.get(kind, 0)) >= 4:
			choices.append(kind)
	if choices.is_empty():
		return []
	var material: String = choices[rng.randi_range(0, choices.size() - 1)]
	var result: Array = [material, material, material, material]
	var pure_left := int(input_budget.get("pure_component", 0)) - int(material_spent["pure_component"])
	var base_left := int(input_budget.get(material, 0)) - int(material_spent[material])
	if alloy_enabled and pure_left >= 2 and base_left >= 2 and rng.randf() < 0.32:
		result = [material, "pure_component", material, "pure_component"]
	return result

func _spawn_piece() -> void:
	active_materials = _choose_materials()
	if active_materials.is_empty():
		_end_run("INPUT HOPPERS EMPTY")
		return
	active_shape = next_shape
	next_shape = _random_shape()
	active_pos = Vector2i(4, 1)
	active_rotation = 0
	can_hold = true
	if not grid.fits(active_shape, active_rotation, active_pos):
		_end_run("FORGE CHAMBER FULL")

func _process(delta: float) -> void:
	if not running or paused or finished:
		return
	elapsed += delta
	gravity_timer += delta
	var interval: float = max(0.09, float(config.get("gravity_seconds", 0.62)) * (1.0 - min(heat, 1.0) * 0.34))
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		interval *= 0.11
	if gravity_timer >= interval:
		gravity_timer = 0.0
		if not _move(Vector2i(0, 1)):
			_lock_piece()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	if not event.pressed:
		return
	if event.keycode == KEY_ESCAPE:
		_end_run("RETURN TO THE LOFT")
		get_viewport().set_input_as_handled()
		return
	if event.keycode == KEY_P:
		if paused:
			resume()
		else:
			pause()
		queue_redraw()
		get_viewport().set_input_as_handled()
		return
	if not running or paused or finished:
		return
	match event.keycode:
		KEY_LEFT, KEY_A:
			_move(Vector2i(-1, 0))
		KEY_RIGHT, KEY_D:
			_move(Vector2i(1, 0))
		KEY_UP, KEY_W, KEY_X:
			if not event.echo:
				_rotate_piece()
		KEY_SPACE:
			if not event.echo:
				while _move(Vector2i(0, 1)):
					pass
				_lock_piece()
		KEY_C:
			if not event.echo:
				_hold_piece()
	queue_redraw()
	get_viewport().set_input_as_handled()

func _move(delta: Vector2i) -> bool:
	var candidate := active_pos + delta
	if grid.fits(active_shape, active_rotation, candidate):
		active_pos = candidate
		return true
	return false

func _rotate_piece() -> void:
	for offset in [0, -1, 1, -2, 2]:
		var candidate := active_pos + Vector2i(offset, 0)
		if grid.fits(active_shape, active_rotation + 1, candidate):
			active_rotation += 1
			active_pos = candidate
			return

func _hold_piece() -> void:
	if not can_hold:
		return
	hold_used = true
	can_hold = false
	if held_shape == "":
		held_shape = active_shape
		active_shape = next_shape
		next_shape = _random_shape()
	else:
		var outgoing := active_shape
		active_shape = held_shape
		held_shape = outgoing
	active_rotation = 0
	active_pos = Vector2i(4, 1)
	if not grid.fits(active_shape, active_rotation, active_pos):
		_end_run("FORGE CHAMBER FULL")

func _lock_piece() -> void:
	if finished:
		return
	for material in active_materials:
		material_spent[material] = int(material_spent.get(material, 0)) + 1
	var outcome: Dictionary = grid.lock(active_shape, active_rotation, active_pos, active_materials)
	pieces_locked += 1
	heat = min(1.0, heat + 0.018)
	var rows: Array = outcome.get("cleared_rows", [])
	if not rows.is_empty():
		lines_cleared += rows.size()
		score += rows.size() * rows.size() * 100
		heat = min(1.0, heat + rows.size() * 0.07)
		if rows.size() == 4:
			tetrises += 1
			score += 400
		for row in rows:
			material_produced["packed_block"] += 1
			if int(row.get("salvage", 0)) >= 4:
				material_produced["stabilized_frame"] += 1
			if int(row.get("pure_component", 0)) >= 2:
				material_produced["forged_blank"] += 1
		status = "%d COMPLETE ROWS CRYSTALLIZED / OUTPUT EJECTED" % rows.size()
	else:
		status = "%s BATCH PACKED INTO FORGE" % active_shape
	if bool(outcome.get("overflow", false)):
		_end_run("MATERIAL OVERFLOW")
	elif lines_cleared >= target_lines:
		_end_run("OUTPUT QUOTA MET")
	else:
		_spawn_piece()

func _end_run(reason: String) -> void:
	if finished:
		return
	finished = true
	running = false
	status = reason
	# Any uncrystallized locked cells become scrap; completed rows have left the grid.
	material_produced["scrap"] = int(grid.remaining_cells() / 5)
	minigame_finished.emit({
		"win": lines_cleared >= target_lines,
		"score": score,
		"materials_consumed": material_spent.duplicate(true),
		"materials_produced": material_produced.duplicate(true),
		"forge_heat": snappedf(heat, 0.01),
		"stats": {"lines": lines_cleared, "tetrises": tetrises, "hold_used": hold_used, "pieces": pieces_locked, "seconds": snappedf(elapsed, 0.1)},
		"station": "tetris_forge_foundry",
		"reason": reason
	})

func _caption(value: String, x: float, y: float, pixel_size: int = 18, tint: Color = Color("e5edf1")) -> void:
	draw_string(get_theme_default_font(), Vector2(x, y), value, HORIZONTAL_ALIGNMENT_LEFT, -1, pixel_size, tint)

func _remaining_fraction(kind: String) -> float:
	var total := int(input_budget.get(kind, 0))
	if total <= 0:
		return 0.0
	return float(maxi(total - int(material_spent.get(kind, 0)), 0)) / float(total)

func _draw() -> void:
	# Every draw call below is presentation-only. The existing grid, gravity,
	# item IDs, held piece, inventory receipts and finished signal are unchanged.
	draw_rect(Rect2(Vector2.ZERO, size), Color("030a13"))
	var zoom: float = minf(size.x / 1280.0, size.y / 800.0)
	var origin := (size - Vector2(1280, 800) * zoom) / 2.0
	draw_set_transform(origin, 0.0, Vector2(zoom, zoom))
	ConsoleSkin.draw_background(self, Vector2(1280, 800), elapsed)

	# Mechanical title masthead.
	ConsoleSkin.draw_panel(self, Rect2(23, 17, 1233, 78), true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(45, 56), Vector2(57, 34), Vector2(69, 56), Vector2(57, 78)
	]), Color("dabb81"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(51, 56), Vector2(57, 45), Vector2(63, 56), Vector2(57, 67)
	]), Color("8c98d7"))
	_caption("GERTECH  /  FORGE FOUNDRY", 85, 57, 29, Color("f2e6cf"))
	_caption("MODULAR MATERIAL PACKING CONSOLE", 87, 80, 14, Color("a9d8e1"))
	_caption("10 x 20", 1123, 51, 19, Color("e7c891"))
	_caption("FABRICATION GRID", 1051, 75, 13, Color("a9bfc8"))

	# Left-side material supply (same actual inventory values).
	ConsoleSkin.draw_panel(self, Rect2(23, 109, 419, 618))
	_caption("SHARED MATERIAL INTAKE", 45, 149, 21, Color("efdfbb"))
	var supplies := [
		{"id": "ore", "name": "ORE", "tone": Color("f1bd77")},
		{"id": "salvage", "name": "SALVAGE", "tone": Color("84d1f0")},
		{"id": "pure_component", "name": "PURE COMPONENT", "tone": Color("ddd2ff")}
	]
	for i in range(supplies.size()):
		var s: Dictionary = supplies[i]
		var key: String = str(s["id"])
		var row_y := 169.0 + float(i) * 65.0
		ConsoleSkin.draw_feed_meter(self, Rect2(42, row_y, 380, 57), _remaining_fraction(key), s["tone"], key)
		_caption(str(s["name"]), 111, row_y + 24, 18, Color("eff4f6"))
		_caption("%d / %d" % [maxi(0, int(input_budget.get(key, 0)) - int(material_spent.get(key, 0))), int(input_budget.get(key, 0))], 321, row_y + 24, 16, s["tone"])
	_caption("ALLOY  " + ("ENABLED" if alloy_enabled else "OFFLINE"), 45, 395, 16, Color("bcd9d9"))
	ConsoleSkin.draw_section(self, Rect2(42, 411, 380, 91), Color("b6a4df"))
	_caption("NEXT", 59, 432, 18, Color("f0ddb2"))
	_caption("HOLD", 254, 432, 18, Color("f0ddb2"))
	_draw_piece_icon(next_shape, Vector2(75, 449))
	_draw_piece_icon(held_shape, Vector2(272, 449))
	_caption("LINES  %02d / %02d" % [lines_cleared, target_lines], 45, 538, 23, Color("f2e8d7"))
	_caption("SCORE  %06d" % score, 45, 572, 21, Color("b7e3e9"))
	_caption("FORGE HEAT   %d%%" % int(heat * 100.0), 45, 605, 17, Color("f0c89b"))
	ConsoleSkin.draw_heat(self, Rect2(42, 615, 380, 51), heat)
	_caption("ONE SHARED STOCK / MATERIALS RETAIN VALUE", 45, 699, 13, Color("a0c8cb"))

	# Physical packing chamber: darker cavities, gold rings, cut crystal cells.
	var chamber := Rect2(457, 109, 312, 618)
	ConsoleSkin.draw_chamber(self, chamber, elapsed)
	_caption("VERTICAL PACKING CHAMBER", 476, 133, 14, Color("f2d2a0"))
	var anchor := Vector2(473, 146)
	var cell_size := 28.0
	if grid != null:
		for y in range(TetrominoGrid.HEIGHT):
			for x in range(TetrominoGrid.WIDTH):
				var rect := Rect2(anchor + Vector2(x, y) * cell_size, Vector2(cell_size - 0.8, cell_size - 0.8))
				var kind: String = grid.at(Vector2i(x, y))
				CellSkin.draw_cell(self, rect, kind)
		if not finished and active_shape != "" and active_materials.size() >= 4:
			# Projected placement appears in a faint gold outline; grid is not mutated.
			var ghost_pos := active_pos
			for _trial in range(TetrominoGrid.HEIGHT + 4):
				var below := ghost_pos + Vector2i(0, 1)
				if grid.fits(active_shape, active_rotation, below):
					ghost_pos = below
				else:
					break
			if ghost_pos != active_pos:
				for p in grid.occupied(active_shape, active_rotation, ghost_pos):
					if p.y >= 0 and p.y < TetrominoGrid.HEIGHT:
						var ghost_rect := Rect2(anchor + Vector2(p) * cell_size, Vector2(cell_size - 0.8, cell_size - 0.8))
						CellSkin.draw_ghost_cell(self, ghost_rect)
			var points := grid.occupied(active_shape, active_rotation, active_pos)
			for i in range(points.size()):
				var p: Vector2i = points[i]
				if p.y >= 0 and p.y < TetrominoGrid.HEIGHT:
					var rect := Rect2(anchor + Vector2(p) * cell_size, Vector2(cell_size - 0.8, cell_size - 0.8))
					CellSkin.draw_cell(self, rect, str(active_materials[i]), true)
	_caption("CRYSTAL / GOLD MODULES  -  VISUAL ONLY", 471, 717, 12, Color("b5c6cd"))

	# Output receipts are exactly the same actual values as the original.
	ConsoleSkin.draw_panel(self, Rect2(785, 109, 472, 618))
	_caption("OUTPUT RECEIPTS", 807, 150, 21, Color("efdfbb"))
	var outputs := [
		{"label": "PACKED BLOCK", "key": "packed_block", "tone": Color("d9bf82")},
		{"label": "STABILIZED FRAME", "key": "stabilized_frame", "tone": Color("8ccde7")},
		{"label": "FORGED BLANK", "key": "forged_blank", "tone": Color("c6b9ed")}
	]
	for i in range(outputs.size()):
		var out: Dictionary = outputs[i]
		var y := 167.0 + float(i) * 70.0
		ConsoleSkin.draw_output(self, Rect2(803, y, 437, 62), int(material_produced[out["key"]]), out["tone"])
		_caption(str(out["label"]), 852, y + 27, 17, Color("f1f3f2"))
		_caption("%d" % int(material_produced[out["key"]]), 1132, y + 28, 22, out["tone"])
	_caption("UNFINISHED STOCK RETURNS AS SCRAP", 808, 404, 16, Color("b9c8d2"))
	_caption("CONTROLS", 808, 442, 18, Color("f0ddb2"))
	_caption("A / D OR LEFT / RIGHT    MOVE", 808, 468, 15)
	_caption("W / X OR UP              ROTATE", 808, 495, 15)
	_caption("S OR DOWN                 SOFT DROP", 808, 522, 15)
	_caption("SPACE                     PACK", 808, 549, 15)
	_caption("C HOLD   /   P PAUSE   /   ESC EXIT", 808, 576, 15)
	_caption("MACHINE STATUS", 808, 620, 17, Color("f0ddb2"))
	ConsoleSkin.draw_section(self, Rect2(803, 631, 437, 74), Color("90ccd5"))
	_caption(status.substr(0, 38), 814, 672, 16, Color("c4f0e6"))

	ConsoleSkin.draw_panel(self, Rect2(23, 741, 1234, 40))
	ConsoleSkin.draw_flow(self, Rect2(35, 746, 123, 30))
	_caption("MATERIAL RECEIVED", 175, 767, 15, Color("e9d7aa"))
	_caption("/", 359, 767, 15, Color("92afb8"))
	_caption("GRID PACKED", 399, 767, 15, Color("e9d7aa"))
	_caption("/", 558, 767, 15, Color("92afb8"))
	_caption("OUTPUT RECORDED TO SHARED LOFT STOCK", 598, 767, 15, Color("b6d9df"))
	if paused:
		ConsoleSkin.draw_panel(self, Rect2(477, 377, 278, 110), true)
		_caption("FORGE PAUSED", 512, 441, 26, Color("ffdf9e"))
	draw_set_transform(Vector2.ZERO)

func _draw_piece_icon(piece: String, top_left: Vector2) -> void:
	if piece == "":
		_caption("EMPTY", top_left.x + 14, top_left.y + 33, 15, Color("91a9b8"))
		return
	var empty_grid := GridScript.new()
	for p in empty_grid.rotated(piece, 0):
		CellSkin.draw_preview_cell(self, Rect2(top_left + Vector2(p) * 20.0, Vector2(19, 19)))
