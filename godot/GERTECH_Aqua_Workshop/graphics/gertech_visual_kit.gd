extends RefCounted
class_name GertechVisualKit

# VISUAL-ONLY. These drawn parts do not add WorldSeed vertices, physical
# connections, material items, inventory events, or functional machine ports.
# Reference language: transparent crystal housing + nebula interior +
# visible gold framing and mechanical end fittings.
const GALAXY_SHADER = preload("res://graphics/gertech_galaxy.gdshader")

static func material(hex_color: String, metal: float = 0.0, rough: float = 0.28, alpha: float = 1.0) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = Color(hex_color)
    m.albedo_color.a = alpha
    m.metallic = metal
    m.roughness = rough
    if alpha < 1.0:
        m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        m.cull_mode = BaseMaterial3D.CULL_DISABLED
    return m

static func gold() -> Material:
    return material("f0bd5a", 0.91, 0.17)

static func glass() -> Material:
    return material("a6e3ff", 0.16, 0.11, 0.20)

static func ceramic() -> Material:
    return material("e7e5d9", 0.10, 0.22)

static func galaxy() -> ShaderMaterial:
    var m := ShaderMaterial.new()
    m.shader = GALAXY_SHADER
    return m

static func _box(parent: Node3D, label: String, pos: Vector3, extents: Vector3, mat: Material) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    n.name = label
    var mesh := BoxMesh.new()
    mesh.size = extents
    n.mesh = mesh
    n.material_override = mat
    n.position = pos
    parent.add_child(n)
    return n

static func display_cube(parent: Node3D, center: Vector3, side: float, label: String = "DISPLAY_CUBE") -> Node3D:
    var n := Node3D.new()
    n.name = label + "_PRESENTATION_ONLY"
    n.position = center
    parent.add_child(n)
    var g := gold()
    _box(n, "Galaxy_Interior", Vector3.ZERO, Vector3.ONE * side * 0.86, galaxy())
    _box(n, "Clear_Crystal_Shell", Vector3.ZERO, Vector3.ONE * side, glass())
    var edge_width := side * 0.045
    var half := side * 0.5
    for axis in range(3):
        for a in [-1.0, 1.0]:
            for b in [-1.0, 1.0]:
                var p := Vector3.ZERO
                var scale := Vector3(edge_width, edge_width, edge_width)
                scale[axis] = side
                p[(axis + 1) % 3] = a * half
                p[(axis + 2) % 3] = b * half
                _box(n, "Gold_Edge_Casing", p, scale, g)
    for x in [-1.0, 1.0]:
        for y in [-1.0, 1.0]:
            for z in [-1.0, 1.0]:
                _box(n, "Machined_Corner_Mount", Vector3(x, y, z) * half, Vector3.ONE * side * 0.14, g)
    return n

static func display_prism(parent: Node3D, center: Vector3, side: float, label: String = "DISPLAY_PRISM") -> Node3D:
    var n := Node3D.new()
    n.name = label + "_PRESENTATION_ONLY"
    n.position = center
    parent.add_child(n)
    var mesh := PrismMesh.new()
    mesh.size = Vector3(side, side, side)
    var inside := MeshInstance3D.new()
    inside.mesh = mesh
    inside.material_override = galaxy()
    n.add_child(inside)
    var halo := MeshInstance3D.new()
    halo.mesh = mesh
    halo.scale = Vector3.ONE * 1.06
    halo.material_override = glass()
    n.add_child(halo)
    # Explicit visual edging. Never considered validated structural ports.
    var gold_mat := gold()
    for x in [-side * 0.49, side * 0.49]:
        _box(n, "Gold_Base_Trim", Vector3(x, -side * 0.50, 0), Vector3(side * 0.06, side * 0.07, side), gold_mat)
    return n
