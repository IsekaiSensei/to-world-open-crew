extends RefCounted
class_name GertechFoundryCellSkin

# Visual-only GERTECH manufactured cell language. No grid or material mutations.
# Never interpret decorative corner sockets as valid WorldSeed port connections.

static func _chamfer(r: Rect2, cut: float) -> PackedVector2Array:
    var l := r.position.x
    var t := r.position.y
    var rr := r.end.x
    var bb := r.end.y
    return PackedVector2Array([
        Vector2(l + cut, t), Vector2(rr - cut, t),
        Vector2(rr, t + cut), Vector2(rr, bb - cut),
        Vector2(rr - cut, bb), Vector2(l + cut, bb),
        Vector2(l, bb - cut), Vector2(l, t + cut)
    ])

static func _palette(kind: String) -> Dictionary:
    match kind:
        "ore":
            return {"hull": Color("8d6135"), "core": Color("c17c45"), "light": Color("ffdaa2"), "glyph": Color("fff2d7")}
        "salvage":
            return {"hull": Color("276276"), "core": Color("377f9e"), "light": Color("a9f0ff"), "glyph": Color("f3fcff")}
        "pure_component":
            return {"hull": Color("5e5b87"), "core": Color("9995d8"), "light": Color("e9e6ff"), "glyph": Color("ffffff")}
        _:
            return {"hull": Color("536581"), "core": Color("7388aa"), "light": Color("e6f2ff"), "glyph": Color("ffffff")}

static func draw_cell(canvas: CanvasItem, rect: Rect2, material_id: String, active: bool = false) -> void:
    # Every cell is a framed cavity, not a uniform arcade-colored square.
    if material_id == "":
        canvas.draw_rect(rect, Color("061522"))
        canvas.draw_colored_polygon(_chamfer(rect.grow(-1.0), 2.0), Color("112838"))
        canvas.draw_rect(rect.grow(-4.0), Color("071b2b"))
        canvas.draw_line(rect.position + Vector2(3, 3), rect.position + Vector2(rect.size.x - 4, 3), Color("3e5967"), 1.0)
        canvas.draw_line(rect.position + Vector2(3, rect.size.y - 4), rect.position + Vector2(8, rect.size.y - 4), Color("6c5841", 0.55), 1.0)
        return
    var tone: Dictionary = _palette(material_id)
    var gold := Color("d7b77a") if not active else Color("fff2ba")
    var core_color: Color = tone["core"]
    var hull_color: Color = tone["hull"]
    var light_color: Color = tone["light"]
    var glyph_color: Color = tone["glyph"]
    # Two-stage recessed fabricated housing with cut edges.
    canvas.draw_rect(rect, Color("030d16"))
    canvas.draw_colored_polygon(_chamfer(rect.grow(-0.7), 3.0), gold.darkened(0.46))
    canvas.draw_colored_polygon(_chamfer(rect.grow(-2.2), 3.1), Color("091725"))
    canvas.draw_colored_polygon(_chamfer(rect.grow(-4.3), 2.9), hull_color)
    canvas.draw_colored_polygon(_chamfer(rect.grow(-6.2), 2.4), Color("0d1932"))
    canvas.draw_colored_polygon(_chamfer(rect.grow(-7.6), 2.0), core_color.darkened(0.25))
    # The layer inside the shell glows; it does not imply a resource or port.
    var mid := rect.get_center()
    canvas.draw_circle(mid + Vector2(1, 1), rect.size.x * 0.24, Color(light_color.r, light_color.g, light_color.b, 0.10))
    canvas.draw_arc(mid, rect.size.x * 0.235, 3.7, 5.5, 10, Color(light_color.r, light_color.g, light_color.b, 0.67), 1.1, true)
    canvas.draw_arc(mid, rect.size.x * 0.18, 0.1, 1.9, 10, Color(light_color.r, light_color.g, light_color.b, 0.38), 1.0, true)
    canvas.draw_circle(mid + Vector2(-5, -4), 1.2, Color("fbfcff"))
    canvas.draw_circle(mid + Vector2(5, 3), 0.8, light_color)
    # Machined gold structural rails + corner contact *visuals*.
    var p := rect.position
    var s := rect.size
    canvas.draw_line(p + Vector2(4, 3), p + Vector2(s.x - 4, 3), gold, 1.3)
    canvas.draw_line(p + Vector2(3, 4), p + Vector2(3, s.y - 4), gold.darkened(0.21), 1.1)
    canvas.draw_line(p + Vector2(4, s.y - 3), p + Vector2(s.x - 4, s.y - 3), gold.darkened(0.29), 1.0)
    canvas.draw_line(p + Vector2(s.x - 3, 4), p + Vector2(s.x - 3, s.y - 4), gold.darkened(0.24), 1.0)
    for u in [Vector2(4.2, 4.2), Vector2(s.x - 4.2, 4.2), Vector2(4.2, s.y - 4.2), Vector2(s.x - 4.2, s.y - 4.2)]:
        canvas.draw_circle(p + u, 2.1, Color("f3d99d"))
        canvas.draw_circle(p + u, 0.9, Color("3e2919"))
    # Material identification by SHAPE as well as color.
    match material_id:
        "ore":
            canvas.draw_colored_polygon(PackedVector2Array([
                mid + Vector2(0, -5.3), mid + Vector2(-5.1, 4.4), mid + Vector2(5.1, 4.4)
            ]), glyph_color)
            canvas.draw_line(mid + Vector2(0, -4.2), mid + Vector2(0, 2.1), Color("80552a"), 1.0)
        "salvage":
            canvas.draw_line(mid + Vector2(-5.6, 5.0), mid + Vector2(4.8, -5.1), glyph_color, 2.3, true)
            canvas.draw_line(mid + Vector2(-2.2, 5.2), mid + Vector2(5.0, -2.0), Color("132d41"), 1.5, true)
        "pure_component":
            canvas.draw_arc(mid, 4.4, 0.0, TAU, 16, glyph_color, 2.1, true)
            canvas.draw_circle(mid, 1.8, Color("13273b"))
        _:
            canvas.draw_circle(mid, 3.2, glyph_color)
    if active:
        canvas.draw_rect(rect.grow(-1.0), Color("fff3c5"), false, 2.0)

static func draw_ghost_cell(canvas: CanvasItem, rect: Rect2) -> void:
    canvas.draw_colored_polygon(_chamfer(rect.grow(-2.0), 3.0), Color("caac78", 0.13))
    var points := _chamfer(rect.grow(-2.0), 3.0)
    points.append(points[0])
    canvas.draw_polyline(points, Color("e7d6a9", 0.62), 1.3, true)
    canvas.draw_circle(rect.get_center(), 1.5, Color("d8c28e", 0.62))

static func draw_preview_cell(canvas: CanvasItem, rect: Rect2) -> void:
    draw_cell(canvas, rect, "pure_component", false)
