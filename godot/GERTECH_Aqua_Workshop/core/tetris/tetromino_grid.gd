extends RefCounted
class_name TetrominoGrid

# Core grid rules: no reference to GERTECH, foundries, colors or materials.
const WIDTH := 10
const HEIGHT := 20
const SHAPES := {
	"I": [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)],
	"O": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
	"T": [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)],
	"L": [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1)],
	"J": [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 1)],
	"S": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 1), Vector2i(0, 1)],
	"Z": [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)]
}
var cells: Array = []

func _init() -> void:
	for y in HEIGHT:
		var row: Array = []
		for x in WIDTH:
			row.append("")
		cells.append(row)

func at(p: Vector2i) -> String:
	if p.x < 0 or p.x >= WIDTH or p.y < 0 or p.y >= HEIGHT:
		return ""
	return str(cells[p.y][p.x])

func rotated(shape: String, turns: int) -> Array:
	var result: Array = []
	for raw in SHAPES[shape]:
		var p: Vector2i = raw
		if shape != "O":
			for _n in range(posmod(turns, 4)):
				p = Vector2i(-p.y, p.x)
		result.append(p)
	return result

func occupied(shape: String, rotation: int, origin: Vector2i) -> Array:
	var points: Array = []
	for p in rotated(shape, rotation):
		points.append(origin + p)
	return points

func fits(shape: String, rotation: int, origin: Vector2i) -> bool:
	for p in occupied(shape, rotation, origin):
		if p.x < 0 or p.x >= WIDTH or p.y >= HEIGHT:
			return false
		if p.y >= 0 and at(p) != "":
			return false
	return true

func lock(shape: String, rotation: int, origin: Vector2i, materials: Array) -> Dictionary:
	var overflow := false
	var points := occupied(shape, rotation, origin)
	for index in range(points.size()):
		var p: Vector2i = points[index]
		if p.y < 0:
			overflow = true
		else:
			cells[p.y][p.x] = str(materials[index])
	var rows: Array = []
	var y := HEIGHT - 1
	while y >= 0:
		var row: Array = cells[y]
		var solid := true
		for cell in row:
			if cell == "":
				solid = false
				break
		if solid:
			var tally: Dictionary = {}
			for cell in row:
				tally[cell] = int(tally.get(cell, 0)) + 1
			rows.append(tally)
			cells.remove_at(y)
			var empty: Array = []
			for i in WIDTH:
				empty.append("")
			cells.insert(0, empty)
		else:
			y -= 1
	return {"cleared_rows": rows, "overflow": overflow}

func remaining_cells() -> int:
	var count := 0
	for row in cells:
		for cell in row:
			if cell != "":
				count += 1
	return count
