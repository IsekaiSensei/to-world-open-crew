# Godot 4 *illustrative* viewer for the JSON world seed bridge example.
# Not yet run in Godot. Put this script on an empty Node3D, set seed_file.
# Unsupported modules are skipped with warnings; source identity is never substituted.
extends Node3D

@export_file("*.json") var seed_file := "res://examples/bridge_seed.json"
@export var gold_frame_color := Color(0.72, 0.53, 0.19)
@export var frame_thickness: float = 0.045

func _ready() -> void:
    if not FileAccess.file_exists(seed_file):
        push_error("World seed not found: " + seed_file)
        return
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(seed_file))
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("World seed must be JSON object")
        return
    if parsed.get("status", "") == "incomplete":
        push_error("Construction source incomplete. Original 38-module Corvette geometry not yet resolved.")
        return
    for part in parsed.get("instances", []):
        var part_id: String = part.get("id", "unknown")
        var template_id: String = part.get("template", "")
        if template_id != "geom:cube_frame":
            push_warning("No preview mesh binding for " + template_id + "; skipping " + part_id)
            continue
        var frame := Node3D.new()
        frame.name = part_id
        add_child(frame)
        var pose: Dictionary = part.get("pose", {})
        var xyz: Array = pose.get("position", [0, 0, 0])
        frame.position = Vector3(float(xyz[0]), float(xyz[1]), float(xyz[2]))
        frame.rotation_degrees.y = float(pose.get("yaw_deg", 0))
        _add_frame_geometry(frame)

func _add_frame_geometry(root: Node3D) -> void:
    var gold := StandardMaterial3D.new()
    gold.albedo_color = gold_frame_color
    gold.metallic = 0.78
    gold.roughness = 0.23
    # Twelve beams, actual geometry, with consistent shared cube-frame topology.
    for x in [-0.5, 0.5]:
        for y in [-0.5, 0.5]:
            _beam(root, Vector3(x, y, 0), Vector3(frame_thickness, frame_thickness, 1), gold)
    for x in [-0.5, 0.5]:
        for z in [-0.5, 0.5]:
            _beam(root, Vector3(x, 0, z), Vector3(frame_thickness, 1, frame_thickness), gold)
    for y in [-0.5, 0.5]:
        for z in [-0.5, 0.5]:
            _beam(root, Vector3(0, y, z), Vector3(1, frame_thickness, frame_thickness), gold)

func _beam(root: Node3D, at: Vector3, dimensions: Vector3, material: Material) -> void:
    var mesh := BoxMesh.new()
    mesh.size = dimensions
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    visual.position = at
    visual.material_override = material
    root.add_child(visual)