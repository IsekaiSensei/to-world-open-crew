extends RefCounted
class_name GertechFoundryConsoleSkin

# Drawing-only, no inventory, save, graph, grid or input logic.
# High-contrast outline and shape cues supplement material colors.

static func _corners(r: Rect2, cut: float) -> PackedVector2Array:
    var a := r.position
    var b := r.end
    return PackedVector2Array([
        Vector2(a.x + cut, a.y), Vector2(b.x - cut, a.y),
        Vector2(b.x, a.y + cut), Vector2(b.x, b.y - cut),
        Vector2(b.x - cut, b.y), Vector2(a.x + cut, b.y),
        Vector2(a.x, b.y - cut), Vector2(a.x, a.y + cut)
    ])

static func _outline(canvas: CanvasItem, points: PackedVector2Array, color: Color, thickness: float = 1.0) -> void:
    var line := points.duplicate()
    line.append(points[0])
    canvas.draw_polyline(line, color, thickness, true)

static func draw_background(canvas: CanvasItem, bounds: Vector2, tick: float) -> void:
    canvas.draw_rect(Rect2(Vector2.ZERO, bounds), Color("040b13"))
    # Dark foundry wall rather than flat blue GUI background.
    for i in range(16):
        var t := float(i) / 16.0
        canvas.draw_rect(Rect2(0, t * bounds.y, bounds.x, bounds.y / 16.0 + 1.0), Color(0.015 + t * 0.011, 0.033 + t * 0.017, 0.059 + t * 0.020, 1.0))
    # Repeating fixed construction lattice: a visual panel treatment, not WorldSeed edges.
    for x in range(0, 1290, 64):
        canvas.draw_line(Vector2(x, 0), Vector2(x - 145, 800), Color("8a7853", 0.095), 1.0)
    for y in range(6, 800, 64):
        canvas.draw_line(Vector2(0, y), Vector2(1280, y), Color("9cbad0", 0.045), 1.0)
    for i in range(52):
        var xx := float((i * 137 + 33) % 1280)
        var yy := float((i * 263 + 17) % 800)
        var glow := 0.12 + 0.1 * (0.5 + 0.5 * sin(tick * 0.8 + float(i)))
        canvas.draw_circle(Vector2(xx, yy), 1.0, Color(0.63, 0.78, 0.98, glow))

static func draw_panel(canvas: CanvasItem, rect: Rect2, primary: bool = false) -> void:
    # Three-layer cast-metal bezel with clipped corners.
    var border := Color("e0c28b") if primary else Color("74664c")
    canvas.draw_colored_polygon(_corners(rect, 12.0), Color("05090f"))
    canvas.draw_colored_polygon(_corners(rect.grow(-2.0), 10.0), border.darkened(0.47))
    canvas.draw_colored_polygon(_corners(rect.grow(-4.2), 9.5), Color("102130"))
    canvas.draw_colored_polygon(_corners(rect.grow(-7.3), 7.3), Color("0b1825"))
    _outline(canvas, _corners(rect.grow(-2.2), 10.0), Color("e0c28b", 0.83) if primary else Color("89969a", 0.43), 1.2)
    canvas.draw_line(rect.position + Vector2(23, 8), Vector2(rect.end.x - 24, rect.position.y + 8), Color("9dcbdc", 0.25), 1.0)
    for pos in [rect.position + Vector2(17, 17), Vector2(rect.end.x - 17, rect.position.y + 17),
                Vector2(rect.position.x + 17, rect.end.y - 17), rect.end - Vector2(17, 17)]:
        canvas.draw_circle(pos, 3.4, Color("d5bb8b"))
        canvas.draw_circle(pos, 1.5, Color("111922"))

static func draw_section(canvas: CanvasItem, rect: Rect2, accent: Color) -> void:
    canvas.draw_colored_polygon(_corners(rect, 6.0), Color("122a39"))
    _outline(canvas, _corners(rect, 6.0), Color(accent.r, accent.g, accent.b, 0.52), 1.15)
    canvas.draw_line(rect.position + Vector2(12, 4), rect.position + Vector2(rect.size.x * 0.56, 4), Color(accent.r, accent.g, accent.b, 0.49), 1.2)

static func draw_feed_meter(canvas: CanvasItem, rect: Rect2, frac: float, accent: Color, glyph: String) -> void:
    draw_section(canvas, rect, accent)
    var badge := rect.position + Vector2(27, rect.size.y * 0.5)
    canvas.draw_arc(badge, 12.0, 0.0, TAU, 24, Color("d7bd89"), 1.7, true)
    canvas.draw_circle(badge, 8.1, Color("071721"))
    match glyph:
        "ore":
            canvas.draw_colored_polygon(PackedVector2Array([badge + Vector2(0, -5), badge + Vector2(-5, 4), badge + Vector2(5, 4)]), accent)
        "salvage":
            canvas.draw_line(badge + Vector2(-5, 5), badge + Vector2(5, -5), accent, 2.2, true)
        "pure_component":
            canvas.draw_arc(badge, 5.0, 0.0, TAU, 16, accent, 2.1, true)
    var base := Rect2(rect.position + Vector2(65, rect.size.y - 15), Vector2(rect.size.x - 83, 5))
    canvas.draw_rect(base, Color("030a12"))
    canvas.draw_rect(Rect2(base.position, Vector2(base.size.x * clampf(frac, 0.0, 1.0), base.size.y)), accent)
    canvas.draw_rect(base, Color("c9cdd3", 0.44), false, 1.0)

static func draw_output(canvas: CanvasItem, rect: Rect2, amount: int, accent: Color) -> void:
    draw_section(canvas, rect, accent)
    var center := rect.position + Vector2(28, rect.size.y * 0.5)
    canvas.draw_colored_polygon(PackedVector2Array([
        center + Vector2(0, -11), center + Vector2(11, -5), center + Vector2(11, 6),
        center + Vector2(0, 12), center + Vector2(-11, 6), center + Vector2(-11, -5)
    ]), Color("d1b982"))
    canvas.draw_colored_polygon(PackedVector2Array([
        center + Vector2(0, -7), center + Vector2(7, -3), center + Vector2(7, 4),
        center + Vector2(0, 8), center + Vector2(-7, 4), center + Vector2(-7, -3)
    ]), accent.darkened(0.58))
    canvas.draw_line(center + Vector2(0, -7), center + Vector2(0, 8), Color("f3e3be"), 1.1)
    for i in range(mini(6, amount)):
        canvas.draw_rect(Rect2(rect.end.x - 72 + i * 9, rect.end.y - 13, 5, 4), accent)

static func draw_chamber(canvas: CanvasItem, rect: Rect2, tick: float) -> void:
    draw_panel(canvas, rect, true)
    # Machine rails and casting port: these follow the visible 10x20 board, not world nodes.
    var left := rect.position.x + 8.0
    var right := rect.end.x - 8.0
    canvas.draw_line(Vector2(left, rect.position.y + 45), Vector2(left, rect.end.y - 25), Color("b5b4a7"), 2.0)
    canvas.draw_line(Vector2(right, rect.position.y + 45), Vector2(right, rect.end.y - 25), Color("b5b4a7"), 2.0)
    for i in range(10):
        var yy := rect.position.y + 48.0 + i * 55.0
        for xx in [left, right]:
            canvas.draw_circle(Vector2(xx, yy), 3.0, Color("ead39a"))
            canvas.draw_circle(Vector2(xx, yy), 1.1, Color("08121f"))
    canvas.draw_rect(Rect2(rect.position.x + 17, rect.position.y + 33, rect.size.x - 34, 5), Color("987b4a"))
    var pulse := 0.56 + 0.30 * sin(tick * 1.5)
    canvas.draw_circle(Vector2(rect.get_center().x, rect.position.y + 22), 4.0, Color(0.66, 0.87, 1.0, pulse))

static func draw_heat(canvas: CanvasItem, rect: Rect2, heat: float) -> void:
    draw_section(canvas, rect, Color("e6ad70"))
    var track := Rect2(rect.position + Vector2(13, 24), Vector2(rect.size.x - 26, 11))
    canvas.draw_rect(track, Color("03090e"))
    var width := track.size.x * clampf(heat, 0.0, 1.0)
    canvas.draw_rect(Rect2(track.position, Vector2(width, track.size.y)), Color("b96b3b"))
    canvas.draw_rect(Rect2(track.position + Vector2(0, 2), Vector2(width, 4)), Color("f9d698"))
    canvas.draw_rect(track, Color("bfb9a8"), false, 1.0)
    for i in range(1, 10):
        var xx := track.position.x + float(i) * track.size.x / 10.0
        canvas.draw_line(Vector2(xx, track.position.y - 3), Vector2(xx, track.end.y + 3), Color("d8d4c9", 0.5), 1.0)

static func draw_flow(canvas: CanvasItem, rect: Rect2) -> void:
    # Schematic labels only: no implied new production routes or item entries.
    draw_section(canvas, rect, Color("e0bf84"))
    var y := rect.get_center().y
    canvas.draw_line(Vector2(rect.position.x + 28, y), Vector2(rect.end.x - 28, y), Color("b9a377"), 2.0)
    for t in [0.12, 0.32, 0.52, 0.72, 0.91]:
        var x := lerpf(rect.position.x + 28, rect.end.x - 28, t)
        canvas.draw_circle(Vector2(x, y), 5.0, Color("e3c785"))
        canvas.draw_circle(Vector2(x, y), 2.3, Color("112f3b"))
