extends Node3D

# GERTECH AQUA WORKSHOP — explorable environment
# Procedural 3D environment: no asset dependencies and no gameplay requirements.
# The scenes and individual generated props are ordinary Godot nodes at runtime.

var mats: Dictionary = {}
var scene_root: Node3D
var props: Node3D
var details: Node3D
var animated_items: Array[Node3D] = []
var time_elapsed := 0.0
var player: WorkshopExplorer
var location_label: Label
var pulse_label: Label
var inventory: WorkshopInventory
var inventory_label: Label
var interaction_label: Label
var result_label: Label
var output_display: Node3D
var output_counter: Label3D
var active_foundry: MinigameInterface
var foundry_layer: CanvasLayer
var worldseed_renderer: WorldSeedRenderer
var worldseed_label: Label
const FORGE_CONSOLE := Vector3(27.0, 0.0, -14.0)
const EXCHANGE_TERMINAL := Vector3(11.0, 0.0, -19.2)

func _ready() -> void:
	inventory = preload("res://workshop/inventory.gd").new()
	add_child(inventory)
	_build_materials()
	_build_lighting()
	_build_architecture()
	_build_arrival_gallery()
	_build_shell_foundry()
	_build_crystal_gallery()
	_build_living_metal_lab()
	_build_vat_array()
	_build_dna_chamber()
	_build_mouse_maze_exhibit()
	_build_flow_network()
	_build_classic_intake_docks()
	_build_tetris_forge()
	_build_worldseed_lattice()
	_build_player_and_hud()
	inventory.inventory_changed.connect(_refresh_workshop_stock)
	_refresh_workshop_stock()

func _process(delta: float) -> void:
	time_elapsed += delta
	for i in range(animated_items.size()):
		var part: Node3D = animated_items[i]
		if is_instance_valid(part):
			part.rotate_y(delta * (0.1 if i % 2 == 0 else -0.07))
	if location_label != null and player != null:
		var p: Vector3 = player.global_position
		var zone := "CENTRAL WORKSHOP"
		if p.z > 22.0: zone = "ARRIVAL GALLERY"
		elif p.x < -12.0 and p.z > 9.0: zone = "MOUSE MAZE / BEHAVIOR LAB"
		elif p.x < -12.0 and p.z <= -10.0: zone = "CRYSTAL GROWTH"
		elif p.x < -12.0: zone = "SHELL / BIOMINERAL FOUNDRY"
		elif p.x > 12.0 and p.z < -12.0: zone = "TETRIS / FORGE FOUNDRY"
		elif p.x > 12.0 and p.z > 4.0: zone = "SIX-VAT FABRICATION"
		elif p.x > 12.0: zone = "LIVING METAL LAB"
		elif p.z < -13.0: zone = "DNA HELIX / POCKET APERTURE"
		location_label.text = "LOCATION  /  " + zone
		if pulse_label != null:
			pulse_label.text = "AQUA  •  GERTECH  •  " + ("FREE CAMERA" if player.fly_mode else "WALKTHROUGH")
	if inventory_label != null:
		inventory_label.text = inventory.summary()
	if worldseed_label != null:
		worldseed_label.text = inventory.seed.summary()
	if interaction_label != null:
		interaction_label.text = ""
		if active_foundry == null and player != null:
			if player.global_position.distance_to(FORGE_CONSOLE) < 6.5:
				interaction_label.text = "E  /  OPERATE THE TETRIS FORGE FOUNDRY"
			elif player.global_position.distance_to(EXCHANGE_TERMINAL) < 5.6:
				interaction_label.text = "K  /  BUILD MOUSE VISOR CHIP UPGRADE   [4 PACKED + 1 FORGED BLANK]"

func _new_mat(color: Color, metallic := 0.0, rough := 0.6, glow := 0.0, alpha := 1.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.albedo_color.a = alpha
	m.metallic = metallic
	m.roughness = rough
	if glow > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = glow
	if alpha < 0.999:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m

func _build_materials() -> void:
	mats = {
		"floor": _new_mat(Color("182b34"), 0.75, 0.35),
		"floor_alt": _new_mat(Color("243945"), 0.8, 0.32),
		"plinth": _new_mat(Color("13202b"), 0.65, 0.38),
		"structure": _new_mat(Color("405866"), 0.79, 0.29),
		"graphite": _new_mat(Color("111b25"), 0.4, 0.42),
		"black": _new_mat(Color("0a1520"), 0.52, 0.23),
		"pewter": _new_mat(Color("6d8793"), 0.86, 0.25),
		"gold": _new_mat(Color("c6a562"), 0.83, 0.24),
		"bronze": _new_mat(Color("987a54"), 0.75, 0.31),
		"ceramic": _new_mat(Color("b6d1cb"), 0.1, 0.23),
		"chalk": _new_mat(Color("e1dfc4"), 0.03, 0.78),
		"shell": _new_mat(Color("d2b58a"), 0.13, 0.37),
		"carbon": _new_mat(Color("202931"), 0.3, 0.56),
		"tpu": _new_mat(Color("a75a45"), 0.13, 0.59),
		"violet": _new_mat(Color("8d73c5"), 0.15, 0.19, 0.8),
		"aqua": _new_mat(Color("46bfcd"), 0.18, 0.24, 1.5),
		"blue": _new_mat(Color("457cb9"), 0.19, 0.21, 1.2),
		"green": _new_mat(Color("8bc3a0"), 0.13, 0.2, 0.85),
		"amber": _new_mat(Color("f2c877"), 0.16, 0.18, 1.0),
		"red": _new_mat(Color("df7655"), 0.13, 0.22, 1.4),
		"purple_crystal": _new_mat(Color("7c7bd4"), 0.3, 0.1, 0.55, 0.88),
		"blue_crystal": _new_mat(Color("5bbed0"), 0.28, 0.08, 0.65, 0.82),
		"clear_glass": _new_mat(Color("91d0da"), 0.12, 0.12, 0.18, 0.23),
		"smoked_glass": _new_mat(Color("25576d"), 0.2, 0.2, 0.1, 0.38),
		"ocean": _new_mat(Color("063c54"), 0.12, 0.5),
		"stone": _new_mat(Color("1a3e49"), 0.08, 0.92),
		"white_light": _new_mat(Color("dffbfc"), 0.0, 0.2, 1.8),
	}

func _build_lighting() -> void:
	var world := WorldEnvironment.new()
	world.name = "Subsea_Atmosphere"
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("071b2b")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("aec6cb")
	env.ambient_light_energy = 0.65
	env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.name = "Underwater_Caustic_Fill"
	sun.light_color = Color("8fc7d5")
	sun.light_energy = 0.37
	sun.rotation_degrees = Vector3(-38.0, 27.0, 0)
	add_child(sun)
	scene_root = Node3D.new()
	scene_root.name = "AQUA_Complex"
	add_child(scene_root)
	props = Node3D.new()
	props.name = "Stations_And_Equipment"
	scene_root.add_child(props)
	details = Node3D.new()
	details.name = "Architecture_And_Detail"
	scene_root.add_child(details)

func _box(parent: Node3D, tag: String, center: Vector3, size: Vector3, material: Material, solid := false) -> Node3D:
	var mi := MeshInstance3D.new()
	mi.name = tag
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = material
	mi.position = center
	parent.add_child(mi)
	if solid:
		var body := StaticBody3D.new()
		body.name = "Collision"
		body.collision_layer = 1
		body.collision_mask = 0
		mi.add_child(body)
		var shape := CollisionShape3D.new()
		var s := BoxShape3D.new()
		s.size = size
		shape.shape = s
		body.add_child(shape)
	return mi

func _cyl(parent: Node3D, tag: String, pos: Vector3, radius: float, height: float, mat: Material, sides := 18, solid := false) -> Node3D:
	var mi := MeshInstance3D.new()
	mi.name = tag
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = sides
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	parent.add_child(mi)
	if solid:
		var body := StaticBody3D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		mi.add_child(body)
		var cs := CollisionShape3D.new()
		var s := CylinderShape3D.new()
		s.radius = radius
		s.height = height
		cs.shape = s
		body.add_child(cs)
	return mi

func _ball(parent: Node3D, tag: String, pos: Vector3, radius: float, mat: Material, segments := 12) -> Node3D:
	var mi := MeshInstance3D.new()
	mi.name = tag
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = 2.0 * radius
	mesh.radial_segments = segments
	mesh.rings = 8
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	parent.add_child(mi)
	return mi

func _beam(parent: Node3D, tag: String, start: Vector3, finish: Vector3, thickness: float, material: Material, sides := 8) -> Node3D:
	var vec := finish - start
	if vec.length() < 0.001:
		return Node3D.new()
	var mi := _cyl(parent, tag, (start + finish) / 2.0, thickness, vec.length(), material, sides)
	mi.quaternion = Quaternion(Vector3.UP, vec.normalized())
	return mi

func _torus(parent: Node3D, tag: String, pos: Vector3, major: float, tube: float, mat: Material, turn := Vector3.ZERO) -> Node3D:
	var mi := MeshInstance3D.new()
	mi.name = tag
	var mesh := TorusMesh.new()
	mesh.inner_radius = major - tube
	mesh.outer_radius = major + tube
	mesh.rings = 32
	mesh.ring_segments = 9
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = turn
	parent.add_child(mi)
	return mi

func _lamp(pos: Vector3, color: Color, energy := 2.1, distance := 13.0) -> void:
	var light := OmniLight3D.new()
	light.name = "Accent_Light"
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = distance
	light.shadow_enabled = false
	details.add_child(light)

func _text(parent: Node3D, words: String, center: Vector3, size := 28, tint := Color("dff9fc"), turn_y := 0.0) -> Label3D:
	var label := Label3D.new()
	label.name = "SIGN_" + words.substr(0, min(words.length(), 22)).replace(" ", "_")
	label.text = words
	label.font_size = size
	label.pixel_size = 0.0045
	label.outline_size = 4
	label.modulate = tint
	label.position = center
	label.rotation_degrees.y = turn_y
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(label)
	return label

func _station_sign(title: String, subtitle: String, p: Vector3, width := 13.6) -> void:
	_box(props, "Sign_Backing_" + title, p, Vector3(width, 1.65, 0.22), mats["black"])
	_box(props, "Sign_Amber_Rule", p + Vector3(0, -0.77, 0.16), Vector3(width - 0.25, 0.06, 0.07), mats["gold"])
	_text(props, title, p + Vector3(0, 0.26, 0.16), 35)
	_text(props, subtitle, p + Vector3(0, -0.36, 0.16), 18, Color("a5dfe6"))

func _arch(z: float, width := 10.0) -> void:
	for side in [-1.0, 1.0]:
		_box(details, "Arch_Pillar", Vector3(side * width * 0.5, 6.4, z), Vector3(0.5, 12.8, 0.55), mats["structure"])
		_box(details, "Gold_Pillar_Inlay", Vector3(side * width * 0.5, 6.7, z + 0.31), Vector3(0.09, 10.9, 0.09), mats["gold"])
	_box(details, "Arch_Header", Vector3(0, 12.8, z), Vector3(width + 1, 0.65, 0.75), mats["structure"])
	_box(details, "Arch_Light", Vector3(0, 12.25, z), Vector3(width - 0.35, 0.12, 0.2), mats["aqua"])

func _build_architecture() -> void:
	_box(details, "Main_Workshop_Foundation", Vector3(0, -0.5, 0), Vector3(96, 1.0, 77), mats["floor"], true)
	_box(details, "AQUA_Raised_Ceiling", Vector3(0, 15.9, 0), Vector3(96, 1.2, 77), mats["structure"])
	_box(details, "West_Outer_Shell", Vector3(-48.0, 7.3, 0), Vector3(1.2, 14.6, 77.0), mats["structure"], true)
	_box(details, "East_Outer_Shell", Vector3(48.0, 7.3, 0), Vector3(1.2, 14.6, 77.0), mats["structure"], true)
	_box(details, "South_Outer_Shell", Vector3(0, 7.3, 38.5), Vector3(96.0, 14.6, 1.1), mats["structure"], true)
	_box(details, "North_Window_Bottom_Sill", Vector3(0, 1.1, -38.5), Vector3(96.0, 2.2, 1.0), mats["structure"], true)
	_box(details, "North_Window_Top_Lintel", Vector3(0, 13.9, -38.5), Vector3(96.0, 2.5, 1.0), mats["structure"], true)
	_box(details, "North_Observation_Glass", Vector3(0, 7.35, -38.55), Vector3(95, 10.8, 0.27), mats["smoked_glass"], true)
	for x in range(-44, 49, 8):
		_box(details, "Ocean_View_Window_Mullion", Vector3(float(x), 7.3, -38.45), Vector3(0.45, 12.2, 1.15), mats["pewter"])
		_box(details, "Window_Mullion_Light", Vector3(float(x), 7.3, -37.83), Vector3(0.08, 11.4, 0.1), mats["blue"])
	for z in range(-33, 37, 9):
		for x in [-45.8, 45.8]:
			_box(details, "Wall_Rib", Vector3(x, 7.6, float(z)), Vector3(1.1, 14.2, 0.8), mats["pewter"])
			_box(details, "Rib_Gold_Slot", Vector3(x * 0.985, 7.6, float(z)), Vector3(0.13, 13.5, 0.14), mats["gold"])
	for x in range(-42, 43, 6):
		_box(details, "Longitudinal_Roof_Rib", Vector3(float(x), 15.12, 0), Vector3(0.28, 0.5, 75.5), mats["gold"])
	for z in range(-33, 39, 9):
		_box(details, "Transverse_Roof_Truss", Vector3(0, 15.05, float(z)), Vector3(95, 0.44, 0.39), mats["pewter"])
		for x in range(-39, 41, 13):
			_box(details, "Under_Truss_White_Light", Vector3(float(x), 14.72, float(z)), Vector3(5.0, 0.09, 0.3), mats["white_light"])
	# 3x3m floor service panels, gold seams and north-south/east-west transit rails.
	for x in range(-45, 46, 6):
		_box(details, "Floor_Grid_Long", Vector3(float(x), 0.012, 0.0), Vector3(0.06, 0.025, 74.0), mats["bronze"])
	for z in range(-36, 37, 6):
		_box(details, "Floor_Grid_Cross", Vector3(0.0, 0.013, float(z)), Vector3(91, 0.025, 0.06), mats["bronze"])
	for x in [-6.0, 6.0]:
		_box(details, "Central_Promenade_Rail", Vector3(x, 0.025, -1.0), Vector3(0.12, 0.04, 65.0), mats["aqua"])
	for z in [6.0, 22.0]:
		_box(details, "Cross_Promenade_Rail", Vector3(0, 0.025, z), Vector3(92, 0.045, 0.12), mats["gold"])
	for z in [20.5, 5.5, -14.0]:
		_arch(z, 12.5)
	# Deep sea silhouette and luminescent seabed visible through panoramic north wall.
	_box(details, "Subsea_Ridge", Vector3(0, -2.1, -68), Vector3(140, 4.0, 48), mats["stone"])
	for i in range(31):
		var xx := -70.0 + float((i * 19) % 145)
		var zz := -51.0 - float((i * 13) % 34)
		var hh := 1.2 + float((i * 7) % 29) / 7.0
		_cyl(details, "Subsea_Basalt_Chimney", Vector3(xx, hh * 0.44, zz), 0.3 + float(i % 5) * 0.18, hh, mats["stone"], 7)
		if i % 2 == 0:
			_ball(details, "Seabed_Biolume", Vector3(xx, hh + 0.5, zz), 0.2 + float(i % 3) * 0.06, mats["blue"], 8)
	# Workshop zones have raised inset floors and optical border strips rather than dividing walls.
	for zone in [Vector3(-27, -0.03, 0), Vector3(-27, -0.03, -23), Vector3(26, -0.03, 0), Vector3(26, -0.03, 16), Vector3(-27, -0.03, 19), Vector3(2, -0.03, -25)]:
		_box(details, "Zone_Dark_Deck", zone, Vector3(31 if abs(zone.x) > 10 else 22, 0.13, 20 if zone.z < 12 else 16), mats["floor_alt"])

func _workbench(center: Vector3, width: float, depth: float, surface: Material) -> void:
	_box(props, "Machined_Bench_Surface", center + Vector3(0, 1.05, 0), Vector3(width, 0.22, depth), surface, true)
	for xx in [-width * 0.42, width * 0.42]:
		for zz in [-depth * 0.38, depth * 0.38]:
			_box(props, "Workbench_Height_Adjust_Foot", center + Vector3(xx, 0.52, zz), Vector3(0.24, 1.02, 0.24), mats["pewter"])
	_box(props, "Front_Bench_Gold_Inlay", center + Vector3(0, 1.12, depth * 0.5 + 0.01), Vector3(width * 0.9, 0.045, 0.075), mats["gold"])

func _build_arrival_gallery() -> void:
	_station_sign("GERTECH  /  AQUA WORLD", "UNDER SAN DIEGO BAY  •  RESEARCH AND FABRICATION", Vector3(0, 8.6, 37.65), 27.0)
	_text(props, "ENVIRONMENTAL SYSTEMS ONLINE", Vector3(0, 5.8, 37.7), 21)
	_text(props, "MATERIAL FLOW  /  SHELL  →  CRYSTAL  →  LIVING METAL  →  PRINT", Vector3(0, 4.25, 37.7), 21, Color("ffe3ae"))
	_box(props, "Arrival_Inlaid_Sector", Vector3(0, 0.07, 29.3), Vector3(16.4, 0.12, 10), mats["plinth"])
	for x in [-7.9, 7.9]:
		_box(props, "Landing_Light", Vector3(x, 0.15, 29.3), Vector3(0.14, 0.06, 9.2), mats["aqua"])
	for z in [24.6, 33.9]:
		_box(props, "Landing_Gold_Rail", Vector3(0, 0.15, z), Vector3(15.8, 0.08, 0.13), mats["gold"])
	# A suspended architectural globe: honeycomb frame of the earth/bay facility.
	var globe_root := Node3D.new()
	globe_root.name = "Suspended_Aqua_Complex_Map"
	globe_root.position = Vector3(0, 9.1, 28.2)
	props.add_child(globe_root)
	_torus(globe_root, "Equatorial_Ring", Vector3.ZERO, 2.2, 0.05, mats["gold"])
	_torus(globe_root, "Polar_Ring", Vector3.ZERO, 2.2, 0.05, mats["aqua"], Vector3(90, 0, 0))
	_torus(globe_root, "Meridian_Ring", Vector3.ZERO, 2.2, 0.05, mats["pewter"], Vector3(0, 0, 90))
	_ball(globe_root, "Oceanic_Navigator_Core", Vector3.ZERO, 0.67, mats["blue_crystal"])
	for j in range(8):
		var a := TAU * float(j) / 8.0
		_ball(globe_root, "Orbiting_Module", Vector3(cos(a) * 2.2, sin(a) * 0.6, sin(a) * 2.05), 0.13, mats["amber"])
	animated_items.append(globe_root)
	_lamp(Vector3(0, 11.6, 28), Color("90dff0"), 2.5, 12)
	# Visitor galleries on the approach.
	for side in [-1.0, 1.0]:
		var x: float = side * 13.0
		_workbench(Vector3(x, 0, 28.5), 7.0, 3.2, mats["black"])
		_box(props, "Arrival_Console_Screen", Vector3(x, 2.3, 29.5), Vector3(5.4, 2.0, 0.22), mats["smoked_glass"])
		_text(props, "AQUA / SYSTEMS", Vector3(x, 2.55, 29.67), 23, Color("c9f3e4"))
		_text(props, "WORKSHOP MAP  |  OPEN ACCESS", Vector3(x, 2.05, 29.67), 14)

func _spiral_shell(origin: Vector3, scale: float, variant: int) -> void:
	var count := 42
	var prev := origin
	for k in range(count):
		var theta := float(k) / float(count - 1) * PI * 3.7
		var radius := 0.15 + scale * 0.11 * exp(theta * 0.115)
		var p := origin + Vector3(cos(theta) * radius, sin(theta * 0.25) * scale * 0.26, sin(theta) * radius)
		if k > 0:
			_beam(props, "Biomineral_Shell_Curl", prev, p, scale * 0.09, mats["shell"] if variant % 2 == 0 else mats["chalk"], 6)
		prev = p
	for ring in range(7):
		var a := float(ring) * TAU / 7.0
		_ball(props, "Shell_Mineral_Node", origin + Vector3(cos(a) * scale * 0.27, sin(a) * scale * 0.1, sin(a) * scale * 0.27), scale * 0.105, mats["gold"], 8)

func _geared_wheel(origin: Vector3, r: float, mat: Material) -> void:
	var gear := Node3D.new()
	gear.name = "Biomineral_Gear_Assembly"
	gear.position = origin
	props.add_child(gear)
	_torus(gear, "Gear_Rim", Vector3.ZERO, r, 0.11, mat, Vector3(90, 0, 0))
	_cyl(gear, "Gear_Axle", Vector3.ZERO, 0.17, 0.45, mats["bronze"], 12)
	for j in range(12):
		var a := TAU * float(j) / 12.0
		_beam(gear, "Mineral_Spoke", Vector3.ZERO, Vector3(cos(a) * r, sin(a) * r, 0), 0.052, mats["gold"])
		var tooth := _box(gear, "Gear_Tooth", Vector3(cos(a) * r, sin(a) * r, 0), Vector3(0.22, 0.19, 0.31), mat)
		tooth.rotation.z = a

func _build_shell_foundry() -> void:
	_station_sign("01  /  BIOMINERAL FOUNDRY", "SHELLS  •  CALCITE  •  CHALK GEARS  •  CARBON MESH", Vector3(-27, 5.8, 10.2), 18.0)
	_workbench(Vector3(-29, 0, 3.2), 15.0, 4.5, mats["ceramic"])
	for i in range(6):
		var x := -35.0 + float(i) * 2.3
		_cyl(props, "Calcite_Growth_Pedestal", Vector3(x, 1.42, 3.3), 0.85, 0.48, mats["black"])
		_cyl(props, "Growth_Illumination_Ring", Vector3(x, 1.75, 3.3), 0.72, 0.08, mats["aqua"], 18)
		_spiral_shell(Vector3(x, 1.9, 3.3), 0.72 + 0.08 * float(i), i)
	_workbench(Vector3(-27, 0, -4.0), 13.2, 4.8, mats["carbon"])
	for j in range(4):
		_geared_wheel(Vector3(-31.4 + float(j) * 2.8, 2.05 + float(j % 2) * 0.42, -3.85), 0.8 + float(j % 2) * 0.2, mats["chalk"])
	# Microstructure lattices: mineral nodes joined on a carbon scaffold.
	for row in range(5):
		for col in range(7):
			var p := Vector3(-32.2 + col * 0.63, 1.62, -5.0 + row * 0.6)
			_ball(props, "Mineral_Reinforcement_Node", p, 0.09, mats["shell"], 8)
			if col < 6:
				_beam(props, "Carbon_Lattice_Bond", p, p + Vector3(0.63, 0, 0), 0.032, mats["graphite"])
			if row < 4:
				_beam(props, "Carbon_Lattice_Crosslink", p, p + Vector3(0, 0, 0.6), 0.032, mats["graphite"])
	_box(props, "Foundry_Exhaust_Hood", Vector3(-29, 8.65, -0.5), Vector3(15, 1.0, 7.0), mats["pewter"])
	for i in range(6):
		var xx := -35.0 + i * 2.4
		_beam(props, "Vertical_Induction_Tube", Vector3(xx, 7.85, 2.6), Vector3(xx, 4.85, 2.6), 0.1, mats["bronze"])
		_ball(props, "Tungsten_Inspection_Lamp", Vector3(xx, 4.78, 2.6), 0.18, mats["amber"])
	_lamp(Vector3(-28, 8.1, 0), Color("eed5a8"), 2.7, 14)

func _crystal_mesh(radius: float, height: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var mid_y := height * 0.35
	var top := Vector3(0, height * 0.68, 0)
	var bottom := Vector3(0, -height * 0.32, 0)
	for i in range(6):
		var a := TAU * float(i) / 6.0
		var b := TAU * float(i + 1) / 6.0
		var v0 := Vector3(cos(a) * radius, mid_y, sin(a) * radius)
		var v1 := Vector3(cos(b) * radius, mid_y, sin(b) * radius)
		var w0 := Vector3(cos(a) * radius * 0.68, -height * 0.17, sin(a) * radius * 0.68)
		var w1 := Vector3(cos(b) * radius * 0.68, -height * 0.17, sin(b) * radius * 0.68)
		for tri in [[v0, top, v1], [w0, v0, v1], [w0, v1, w1], [bottom, w0, w1]]:
			for v in tri:
				st.add_vertex(v)
	st.generate_normals()
	return st.commit()

func _crystal(parent: Node3D, name_tag: String, p: Vector3, radius: float, height: float, material: Material, tilt := 0.0) -> void:
	var mi := MeshInstance3D.new()
	mi.name = name_tag
	mi.mesh = _crystal_mesh(radius, height)
	mi.material_override = material
	mi.position = p
	mi.rotation_degrees.z = tilt
	parent.add_child(mi)

func _build_crystal_gallery() -> void:
	_station_sign("02  /  CRYSTAL GROWTH", "VACUUM CHAMBERS  •  LIGHT LATTICES  •  FACETED SEEDS", Vector3(-27.5, 6.2, -11.6), 18.4)
	for i in range(5):
		var x := -37.0 + i * 4.9
		var z := -24.0 + float(i % 2) * 2.1
		_cyl(props, "Growth_Reactor_Base", Vector3(x, 0.55, z), 1.65, 1.1, mats["black"], 24, true)
		_torus(props, "Growth_Reactor_Contact", Vector3(x, 1.16, z), 1.47, 0.11, mats["gold"])
		_cyl(props, "Crystal_Growth_Cylinder_Glass", Vector3(x, 3.45, z), 1.5, 4.3, mats["clear_glass"], 26)
		_torus(props, "Growth_Cylinder_Top_Rim", Vector3(x, 5.62, z), 1.5, 0.13, mats["pewter"])
		_cyl(props, "Growth_Seed_Lamp", Vector3(x, 1.3, z), 0.35, 0.12, mats["white_light"])
		for c in range(6):
			var a := TAU * float(c) / 6.0
			_crystal(props, "Vacuum_Crystal_Seed", Vector3(x + cos(a) * 0.7, 2.1 + c % 3 * 0.33, z + sin(a) * 0.7), 0.3, 1.2 + float(c % 3) * 0.35, mats["purple_crystal"] if c % 2 == 0 else mats["blue_crystal"], -10.0 + c * 4.0)
		_crystal(props, "Principal_Seed", Vector3(x, 2.8, z), 0.52, 2.55, mats["blue_crystal"])
		if i in [0, 2, 4]:
			_lamp(Vector3(x, 6.7, z), Color("77b1ee") if i != 2 else Color("aa94ef"), 2.1, 9.0)
	# The big found seed suspended above a seed-analysis bench.
	_workbench(Vector3(-27, 0, -32), 14.0, 2.5, mats["black"])
	for i in range(9):
		var x := -32.3 + float(i) * 1.25
		_crystal(props, "Sorted_Module_Sample", Vector3(x, 1.55, -32), 0.22 + 0.04 * (i % 3), 0.7 + 0.18 * (i % 4), mats["blue_crystal"] if i % 2 else mats["purple_crystal"])
	_text(props, "SEEDS    •    FACETS    •    CONTROLLED DEPOSITION", Vector3(-27, 3.6, -32.7), 20)

func _build_living_metal_lab() -> void:
	_station_sign("03  /  LIVING METAL LAB", "TPU TENDONS  •  OPEN-WEAVE MUSCLE  •  ARTICULATED FRAME", Vector3(26, 6.1, 10.1), 18.2)
	_workbench(Vector3(27, 0, 0), 17.0, 4.8, mats["carbon"])
	# The living-metal leg is an anatomical mesh of flexible fibers, not rigid pistons.
	for leg in range(3):
		var xx := 21.3 + leg * 5.6
		_cyl(props, "Android_Limb_Anchor", Vector3(xx, 1.45, -0.2), 0.5, 0.72, mats["pewter"])
		_ball(props, "Upper_Joint", Vector3(xx, 5.8, -0.2), 0.34, mats["gold"])
		_ball(props, "Knee_Joint", Vector3(xx + 0.36, 3.8, 0), 0.3, mats["gold"])
		_ball(props, "Lower_Joint", Vector3(xx, 1.85, -0.2), 0.28, mats["pewter"])
		for n in range(9):
			var phase := TAU * float(n) / 9.0
			var a := Vector3(xx + cos(phase) * 0.35, 5.7, -0.2 + sin(phase) * 0.32)
			var b := Vector3(xx + 0.3 + cos(phase + 0.32) * 0.28, 3.75, sin(phase + 0.32) * 0.28)
			var c := Vector3(xx + cos(phase + 0.68) * 0.24, 1.9, -0.2 + sin(phase + 0.68) * 0.24)
			_beam(props, "Open_Weave_Upper_Fiber", a, b, 0.045, mats["tpu"], 6)
			_beam(props, "Open_Weave_Lower_Fiber", b, c, 0.043, mats["tpu"], 6)
		for level in range(4):
			var y := 5.15 - level * 0.84
			_torus(props, "Knit_Tendon_Collar", Vector3(xx + 0.13, y, -0.13), 0.38 - level * 0.018, 0.035, mats["bronze"])
		_text(props, ["LIMB  A", "LIMB  B", "LIMB  C"][leg], Vector3(xx, 2.1, 2.53), 17)
	# Human-scale nonsexual engineering mannequin at an assembly frame.
	var ax := 37.7
	_cyl(props, "Android_Assembly_Circular_Dais", Vector3(ax, 0.42, -8.7), 2.0, 0.84, mats["black"], 32, true)
	_torus(props, "Assembly_Inspection_Halo", Vector3(ax, 0.88, -8.7), 1.8, 0.06, mats["aqua"])
	_ball(props, "Android_Head_Ceramic", Vector3(ax, 4.65, -8.7), 0.43, mats["ceramic"])
	_box(props, "Android_Chest_Carbon_Frame", Vector3(ax, 3.55, -8.7), Vector3(1.12, 1.3, 0.52), mats["carbon"])
	_crystal(props, "Assembly_Molten_Gold_Core", Vector3(ax, 3.6, -8.32), 0.24, 0.7, mats["amber"])
	_ball(props, "Android_Pelvis_Mechanical", Vector3(ax, 2.58, -8.7), 0.48, mats["gold"])
	for sign in [-1.0, 1.0]:
		_beam(props, "Android_Arm_Bone", Vector3(ax + sign * 0.7, 3.85, -8.7), Vector3(ax + sign * 1.14, 2.65, -8.7), 0.15, mats["pewter"])
		_beam(props, "Android_Leg_Bone", Vector3(ax + sign * 0.33, 2.28, -8.7), Vector3(ax + sign * 0.45, 1.08, -8.7), 0.16, mats["pewter"])
		_ball(props, "Joint_Node", Vector3(ax + sign * 0.7, 3.85, -8.7), 0.24, mats["violet"])
	# Robotic tool arms reaching toward the anatomical frame.
	for side in [-1.0, 1.0]:
		var origin := Vector3(ax + side * 3.15, 0.75, -9.25)
		_cyl(props, "Assembly_Robot_Base", origin, 0.6, 1.5, mats["structure"])
		_beam(props, "Manipulator_Shoulder", origin + Vector3(0, 0.7, 0), origin + Vector3(-side * 0.5, 2.0, 0), 0.18, mats["gold"])
		_beam(props, "Manipulator_Elbow", origin + Vector3(-side * 0.5, 2.0, 0), origin + Vector3(-side * 1.8, 2.8, 0.1), 0.12, mats["pewter"])
		_ball(props, "Manipulator_Probe", origin + Vector3(-side * 1.8, 2.8, 0.1), 0.16, mats["aqua"])
	_lamp(Vector3(30, 9.5, -3.0), Color("89c8ef"), 2.3, 15)

func _build_vat_array() -> void:
	_station_sign("04  /  FABRICATION ARRAY", "SIX PRINTING VATS  •  GEL  •  LAYERED FRAME  •  WASH AND CURE", Vector3(27, 6.1, 27.2), 18.2)
	for idx in range(6):
		var row: int = idx / 3
		var col := idx % 3
		var xx := 18.9 + col * 7.3
		var zz := 19.0 - row * 7.25
		_cyl(props, "Vat_Zero_Point_Foundation", Vector3(xx, 0.62, zz), 2.25, 1.2, mats["black"], 24, true)
		_cyl(props, "Glass_Fabrication_Cylinder", Vector3(xx, 3.12, zz), 1.97, 4.55, mats["smoked_glass"], 24)
		_torus(props, "Vat_Base_Sensor_Ring", Vector3(xx, 1.02, zz), 2.02, 0.115, mats["aqua"])
		_torus(props, "Vat_Lid_Gold_Rim", Vector3(xx, 5.38, zz), 2.02, 0.13, mats["gold"])
		_cyl(props, "Printer_Upper_Cap", Vector3(xx, 5.61, zz), 1.97, 0.42, mats["pewter"], 24)
		_cyl(props, "Gel_Core", Vector3(xx, 2.4, zz), 1.54, 1.68, mats["clear_glass"], 22)
		for n in range(8):
			var angle := float(n) * TAU / 8
			_beam(props, "Printing_Inner_Lattice", Vector3(xx + cos(angle) * 0.38, 1.46, zz + sin(angle) * 0.38), Vector3(xx + cos(angle + 0.3) * 0.52, 4.4, zz + sin(angle + 0.3) * 0.52), 0.037, mats["gold"])
		_cyl(props, "Printable_Head_Module", Vector3(xx, 4.42, zz), 0.32, 0.55, mats["chalk"])
		_text(props, "VAT %02d" % (idx + 1), Vector3(xx, 3.2, zz + 2.22), 20, Color("d5fcf8"))
		if idx in [0, 2, 4]:
			_lamp(Vector3(xx, 8, zz), Color("9bdfeb"), 1.75, 8.0)
	# Interconnecting service header across all six real vats.
	for xx in [18.9, 26.2, 33.5]:
		_beam(props, "Vat_Rigid_Material_Feed", Vector3(xx, 6.18, 11.65), Vector3(xx, 6.18, 19.0), 0.14, mats["bronze"])
	_beam(props, "Vat_Rigid_Feed_Manifold", Vector3(18.9, 6.18, 15.3), Vector3(33.5, 6.18, 15.3), 0.22, mats["gold"])

func _build_dna_chamber() -> void:
	_station_sign("05  /  GALACTIC ETHER RELAY", "DOUBLE HELIX OPENS THE POCKET DIMENSION", Vector3(2, 6.35, -13.1), 20.0)
	_box(props, "Relay_Assembly_Riser", Vector3(2, 0.38, -26.0), Vector3(15.4, 0.75, 14.2), mats["plinth"])
	for side in [-1.0, 1.0]:
		_box(props, "Relay_Cathedral_Pillar", Vector3(2 + side * 6.4, 5.4, -26.5), Vector3(0.75, 10.3, 0.75), mats["structure"])
		for j in range(7):
			_ball(props, "Relay_Pillar_Knot", Vector3(2 + side * 6.4, 1.2 + j * 1.4, -26.0), 0.14, mats["gold"])
	# Two opposing helical ribbons physically border the visible portal seam.
	var helix := Node3D.new()
	helix.name = "DNA_Helix_Relay_Assembly"
	helix.position = Vector3(2, 1.15, -26.4)
	props.add_child(helix)
	var previous_a := Vector3.ZERO
	var previous_b := Vector3.ZERO
	for i in range(68):
		var f := float(i) / 67.0
		var phi := f * TAU * 2.75
		var radius := 2.8
		var y := f * 9.7
		var a := Vector3(cos(phi) * radius, y, sin(phi) * radius * 0.50)
		var b := Vector3(cos(phi + PI) * radius, y, sin(phi + PI) * radius * 0.50)
		if i > 0:
			_beam(helix, "DNA_Stranded_Rail_A", previous_a, a, 0.095, mats["aqua"])
			_beam(helix, "DNA_Stranded_Rail_B", previous_b, b, 0.095, mats["gold"])
		if i % 4 == 0:
			_beam(helix, "DNA_Crossbrace", a, b, 0.045, mats["pewter"])
			_ball(helix, "DNA_Light_Node", a, 0.125, mats["white_light"])
		previous_a = a
		previous_b = b
	# Split atmosphere panels suggest a stable empty/negative-space seam, not magical particles.
	_box(props, "Pocket_Seam_Dark_Field", Vector3(2, 5.95, -26.5), Vector3(2.65, 8.4, 0.15), mats["black"])
	for sign in [-1.0, 1.0]:
		_box(props, "Pocket_Seam_Luminous_Edge", Vector3(2 + sign * 1.35, 5.85, -26.3), Vector3(0.055, 8.25, 0.08), mats["violet"])
	for k in range(9):
		var y := 2.1 + float(k) * 0.9
		_box(props, "Pocket_Seam_Segment", Vector3(2, y, -26.32), Vector3(1.6 - abs(4 - k) * 0.13, 0.04, 0.055), mats["blue"])
	_torus(props, "Relay_Base_Ring", Vector3(2, 0.85, -26.4), 4.1, 0.16, mats["gold"])
	_torus(props, "Relay_Head_Ring", Vector3(2, 10.92, -26.4), 4.1, 0.16, mats["aqua"])
	_lamp(Vector3(2, 11.3, -26.2), Color("8b99fa"), 3.0, 15)
	_text(props, "POCKET DIMENSION APERTURE", Vector3(2, 2.2, -20.5), 19)

func _maze_wall(p: Vector3, horizontal: bool) -> void:
	_box(props, "Maze_Grid_Wall", p, Vector3(0.73 if horizontal else 0.1, 0.22, 0.1 if horizontal else 0.73), mats["aqua"])

func _build_mouse_maze_exhibit() -> void:
	_station_sign("06  /  BEHAVIOR MAZE", "MOUSE VISOR  •  GUIDE CHIP  •  COCKROACH  •  SNAIL  •  PORTAL", Vector3(-27.2, 5.85, 28.5), 18.2)
	_box(props, "Maze_Diagnostic_Table", Vector3(-27, 0.58, 19), Vector3(16.6, 1.12, 12.6), mats["black"], true)
	_box(props, "Maze_Observation_Glass", Vector3(-27, 1.18, 19), Vector3(15.8, 0.1, 11.8), mats["smoked_glass"])
	var maze := [
		"#############",
		"#S...#....P.#",
		"#.##.#.##.#.#",
		"#....#....#.#",
		"###.##.#....#",
		"#M...R...##.#",
		"#...#...C...#",
		"#############",
	]
	var x0 := -33.45
	var z0 := 15.1
	var unit := 1.07
	for row in range(maze.size()):
		var line: String = maze[row]
		for col in range(line.length()):
			var ch := line.substr(col, 1)
			var p := Vector3(x0 + col * unit, 1.34, z0 + row * unit)
			if ch == "#":
				_box(props, "Maze_Wall_Blk", p, Vector3(1.02, 0.36, 1.02), mats["structure"])
			elif ch == ".":
				_ball(props, "Collectible_Food", p, 0.09, mats["amber"], 8)
			elif ch == "M":
				_ball(props, "VR_Mouse_Body", p, 0.29, mats["ceramic"])
				for ear in [-1.0, 1.0]:
					_ball(props, "Mouse_Ear", p + Vector3(ear * 0.2, 0.22, -0.12), 0.15, mats["shell"])
				_box(props, "VR_Mouse_Visor", p + Vector3(0, 0.04, 0.24), Vector3(0.45, 0.2, 0.17), mats["black"])
			elif ch == "R":
				_ball(props, "Chippable_Cockroach", p, 0.21, mats["bronze"])
				_box(props, "Behavior_Chip_Icon", p + Vector3(0, 0.19, 0), Vector3(0.25, 0.08, 0.25), mats["aqua"])
			elif ch == "S":
				_ball(props, "Slow_Guide_Snail", p, 0.23, mats["shell"])
			elif ch == "C":
				_ball(props, "Carrot_Bait", p, 0.18, mats["red"])
			elif ch == "P":
				_torus(props, "Return_To_Workshop_Portal", p, 0.33, 0.075, mats["violet"], Vector3(90, 0, 0))
	_text(props, "VISOR → CHIP → GUIDE → FOOD / SNAIL → PORTAL", Vector3(-27, 3.2, 25.4), 18, Color("ffd89b"))
	_lamp(Vector3(-27, 8, 20), Color("72c7d8"), 1.9, 12)

func _build_flow_network() -> void:
	# The stations are tied to the central conveyor/manifold: each can feed another.
	var feeds := [
		[Vector3(-27, 8.3, 1), Vector3(-6, 8.3, 1)],
		[Vector3(-27, 8.3, -18), Vector3(-6, 8.3, -18)],
		[Vector3(27, 8.3, -1), Vector3(6, 8.3, -1)],
		[Vector3(27, 8.3, 18), Vector3(6, 8.3, 18)],
		[Vector3(-27, 8.3, 19), Vector3(-6, 8.3, 19)],
	]
	for i in range(feeds.size()):
		var aa: Vector3 = feeds[i][0]
		var bb: Vector3 = feeds[i][1]
		_beam(details, "Pneumatic_Material_Transfer_Line", aa, bb, 0.16, mats["pewter"])
		_beam(details, "Gold_Indication_Line", aa + Vector3(0, 0.32, 0), bb + Vector3(0, 0.32, 0), 0.035, mats["amber"])
		_ball(details, "Valve_Route_Node", bb, 0.38, mats["gold"])
	for x in [-6.0, 6.0]:
		_beam(details, "Main_Material_Header", Vector3(x, 8.3, -30), Vector3(x, 8.3, 26), 0.24, mats["bronze"])
	for z in [-18.0, -1.0, 19.0]:
		_beam(details, "Central_Cross_Feed", Vector3(-6, 8.3, z), Vector3(6, 8.3, z), 0.16, mats["pewter"])
	_box(details, "Network_Router_Control", Vector3(0, 8.3, 5.5), Vector3(4, 1.1, 1.5), mats["black"])
	_text(details, "CLOSED-LOOP FEED SYSTEM", Vector3(0, 8.55, 6.42), 18, Color("fff0c6"))
	# Critical physical routes are labeled, not encoded by color alone.
	_text(details, "BIO → CRYSTAL", Vector3(-12.5, 9.2, -12.2), 20, Color("e5f6eb"))
	_text(details, "METAL → PRINT", Vector3(14.0, 9.2, 7.4), 20, Color("e5f6eb"))
	_text(details, "RELAY ↔ WORKSHOP", Vector3(0, 10.5, -13.0), 19, Color("fff0cb"))


# The Fairy's graph is spatially anchored within the existing workshop.
# It is a view of stored vertices and edges, not a second copy of the world.
func _build_worldseed_lattice() -> void:
	worldseed_renderer = WorldSeedRenderer.new()
	worldseed_renderer.name = "FAIRY_WorldSeed_Graph_Visual_Adapter"
	worldseed_renderer.position = Vector3(0.0, 8.0, -3.0)
	scene_root.add_child(worldseed_renderer)
	worldseed_renderer.setup(inventory.seed)
	_text(props, "FAIRY / WORLD SEED • STORED VERTICES + GOLD JOINTS", Vector3(0, 13.6, 3.0), 15, Color("f5e1b3"))

func _seed_vertex_ids() -> Array[String]:
	# Triangulate the original FAIRY scaffold, not unrelated silhouettes or
	# vehicle/creature subassemblies elsewhere in the persistent realm.
	var result: Array[String] = []
	var origin_id := inventory.seed.scaffold_origin()
	var center: Vector3 = inventory.seed.vertices[origin_id].position
	for id in inventory.seed.vertices:
		var v: SeedVertex = inventory.seed.vertices[id]
		if v.position.distance_to(center) <= 5.6:
			result.append(str(id))
	return result

func _worldseed_action(code: int) -> void:
	var seed := inventory.seed
	var origin := seed.scaffold_origin()
	if code == KEY_G:
		var grower := VertexLatticeGrowth.new()
		grower.setup(seed, 300 + seed.vertices.size())
		var created := grower.grow(origin, 12, 5.5)
		result_label.text = "FAIRY LATTICE / %d NEW EMPTY SOCKETS" % created.size()
	elif code == KEY_B:
		var placed := seed.populate_scaffold("packed_block", 8, "forged_module_placer")
		result_label.text = "FOUNDRY -> WORLD SEED / %d PACKED MODULES PLACED" % placed
	elif code == KEY_V:
		var edge_builder := DelaunayEdges.new()
		var made := edge_builder.triangulate(seed, _seed_vertex_ids(), 0.0, 0.01)
		result_label.text = "XZ DELAUNAY / %d NEW STRUCTURAL JOINTS" % made.size()
	elif code == KEY_T:
		var volume_builder := Delaunay3D.new()
		var data: Dictionary = volume_builder.tetrahedralize(seed, _seed_vertex_ids())
		worldseed_renderer.show_tetra_surfaces = true
		worldseed_renderer._redraw()
		result_label.text = "3D DELAUNAY / %d GOLD JOINTS / %d NEW TETRA CELLS" % [data["edges"].size(), data["tetras"].size()]
	elif code == KEY_Y:
		var already_built := false
		for part in seed.assemblies.values():
			if (part as SeedAssembly).kind == "silhouette_demo":
				already_built = true
		if already_built:
			result_label.text = "SILHOUETTE DEMO ALREADY IN WORLD SEED / SAVED WITH EXISTING ASSEMBLIES"
		else:
			var sampler := SilhouetteTetraMesher.new()
			var options := {
				"source_id": "demo_mask_not_an_owner_identity_reference",
				"max_dimension": 10, "layers": 2, "cell_size": 0.65,
				"max_voxels": 100, "origin": Vector3(14.0, 2.0, 1.0),
				"place_from_inventory": 6, "material": "packed_block"
			}
			var mesh_result := sampler.build_from_image(seed, "res://assets/silhouette/demo_alpha_mask.png", "silhouette_demo", options)
			if bool(mesh_result.get("ok", false)):
				worldseed_renderer.show_tetra_surfaces = true
				worldseed_renderer._redraw()
				result_label.text = "SILHOUETTE -> WORLD SEED / %d VERTICES / %d GOLD JOINTS / %d VOLUME CELLS / %d INVENTORY MODULES" % [mesh_result["vertices"].size(), mesh_result["edges"].size(), mesh_result["tetras"].size(), int(mesh_result["placed_from_inventory"])]
			else:
				result_label.text = "SILHOUETTE BUILD BLOCKED / " + str(mesh_result.get("error", "unknown"))
	if not seed.save_to_disk():
		result_label.text += " / SAVE ERROR"


func _unhandled_input(event: InputEvent) -> void:
	if active_foundry != null or player == null:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E and player.global_position.distance_to(FORGE_CONSOLE) < 6.5:
			_open_foundry()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_K and player.global_position.distance_to(EXCHANGE_TERMINAL) < 5.6:
			if inventory.make_mouse_visor_chip_upgrade():
				result_label.text = "EXCHANGE / NEW VISOR CHIP CAPACITY BUILT FROM FORGED MATERIAL"
			else:
				result_label.text = "EXCHANGE / REQUIRES 4 PACKED BLOCKS AND 1 FORGED BLANK"
			get_viewport().set_input_as_handled()
		elif event.keycode in [KEY_G, KEY_B, KEY_V, KEY_T, KEY_Y]:
			_worldseed_action(event.keycode)
			get_viewport().set_input_as_handled()

func _build_classic_intake_docks() -> void:
	# Seven station mouths connect to one material route; these are physical set pieces,
	# not seven isolated arcade cabinets or implementations of seven minigames.
	var docks: Array = [
		["MOUSE MAZE", "FOOD + GUIDES", Vector3(-9.65, 0, 23.6), "amber"],
		["DIG DUG", "ORE + SOIL", Vector3(-9.65, 0, 13.0), "bronze"],
		["BREAKOUT", "REFINED PARTS", Vector3(-9.65, 0, 2.4), "ceramic"],
		["FROGGER", "DELIVERED STOCK", Vector3(-9.65, 0, -8.2), "green"],
		["ASTEROIDS", "SALVAGE + ROCK", Vector3(9.65, 0, 22.0), "blue"],
		["SPACE INVADERS", "DEFENSE TECH", Vector3(9.65, 0, 11.4), "red"],
		["TETRIS FOUNDRY", "PACKED BLOCKS", Vector3(9.65, 0, -0.2), "gold"],
	]
	for item in docks:
		var title: String = item[0]
		var note: String = item[1]
		var p: Vector3 = item[2]
		var accent: Material = mats[item[3]]
		_box(props, "Dock_Footplate_" + title, p + Vector3(0, 0.22, 0), Vector3(3.9, 0.44, 2.6), mats["plinth"])
		_box(props, "Route_Container_" + title, p + Vector3(0, 1.3, -0.4), Vector3(2.75, 1.65, 1.0), mats["graphite"])
		_box(props, "Intake_Rim_" + title, p + Vector3(0, 2.16, -0.4), Vector3(2.75, 0.13, 1.04), accent)
		_torus(props, "Dock_Route_Wheel_" + title, p + Vector3(0, 2.5, -0.25), 0.4, 0.08, accent, Vector3(90, 0, 0))
		_text(props, title, p + Vector3(0, 3.55, 0.72), 18, Color("ffe5b8"))
		_text(props, note, p + Vector3(0, 3.07, 0.72), 15, Color("cae4e9"))
		_beam(details, "Overhead_Infeed_" + title, p + Vector3(0, 3.22, -0.7), Vector3(5.2 if p.x > 0 else -5.2, 8.15, p.z), 0.085, mats["bronze"])
	_text(details, "7 CLASSICS  →  ONE MATERIAL NETWORK", Vector3(0, 11.4, 13.0), 23, Color("fff0ca"))

func _build_tetris_forge() -> void:
	_station_sign("07  /  TETRIS FORGE FOUNDRY", "DIG DUG + ASTEROIDS IN  /  MODULAR STRUCTURES OUT", Vector3(27.0, 7.25, -12.1), 22.5)
	_box(props, "Forge_Floor", Vector3(27, 0.12, -26), Vector3(27, 0.18, 20), mats["plinth"])
	for xx in [14.25, 39.75]:
		_box(props, "Forge_Thermal_Rail", Vector3(xx, 0.23, -26), Vector3(0.18, 0.09, 19.0), mats["amber"])
	for i in range(3):
		var xx := 16.5 + float(i) * 3.8
		_cyl(props, "Material_Hopper", Vector3(xx, 2.8, -30.5), 1.27, 3.8, mats["graphite"], 12, true)
		_torus(props, "Measured_Input_Ring", Vector3(xx, 4.8, -30.5), 1.32, 0.09, mats["amber"] if i == 0 else mats["aqua"] if i == 1 else mats["white_light"])
		_text(props, ["ORE", "SALVAGE", "ALLOY"][i], Vector3(xx, 4.25, -29.0), 17, Color("ffe4b6"))
		_beam(props, "Hopper_Stock_Pipe", Vector3(xx, 4.0, -30.5), Vector3(25.2, 7.6, -32.0), 0.16, mats["bronze"])
	# Vertically oriented ten-column material casting chamber, with solid blocks.
	_box(props, "Vertical_Casting_Backing", Vector3(30.5, 5.4, -33.2), Vector3(7.6, 9.3, 1.05), mats["black"])
	var visual_rows := ["0011100000", "0001100000", "0011100000", "0111100000", "0000111000", "0011110000", "0001110000", "0011010000", "0111011100", "1101011100", "1100110110", "1111111100", "1111111111", "1111111111", "1111111111", "1111111111"]
	for row in range(18):
		for column in range(10):
			var filled := row >= 2 and visual_rows[row - 2].substr(column, 1) == "1"
			var cell_p := Vector3(27.77 + float(column) * 0.6, 1.33 + float(17 - row) * 0.43, -32.0)
			if filled:
				_box(props, "Solid_Cast_Tetromino_Block", cell_p, Vector3(0.56, 0.39, 0.65), mats["amber"] if row > 13 else mats["aqua"] if row > 9 else mats["chalk"])
			else:
				_box(props, "Forge_Empty_Mold", cell_p + Vector3(0, 0, -0.12), Vector3(0.50, 0.35, 0.04), mats["graphite"])
	for row in range(4):
		_box(props, "Solidified_Complete_Cast_Row", Vector3(30.5, 1.25 + float(row) * 0.43, -31.61), Vector3(6.15, 0.026, 0.05), mats["white_light"])
	for xx in [26.9, 34.1]:
		_box(props, "Forge_Press_Frame", Vector3(xx, 5.4, -32.0), Vector3(0.42, 10.2, 0.8), mats["structure"])
		_cyl(props, "Hot_Exhaust_Stack", Vector3(xx, 10.7, -32), 0.45, 2.7, mats["carbon"])
	_cyl(props, "Smelting_Crucible", Vector3(38.0, 1.28, -27.8), 1.8, 2.2, mats["graphite"], 22, true)
	_cyl(props, "Crucible_Heat", Vector3(38, 2.4, -27.8), 1.55, 0.20, mats["amber"])
	_torus(props, "Crucible_Red_Guard", Vector3(38, 2.43, -27.8), 1.9, 0.12, mats["red"])
	# Loft Codex staging racks: fourteen modular blocks across seven visible tiers.
	for tier in range(7):
		var elevation := 1.05 + float(tier) * 1.04
		_box(props, "Loft_Seven_Tier_Shelf", Vector3(42, elevation - 0.32, -21.1), Vector3(4.0, 0.12, 2.2), mats["pewter"])
		for slot in range(2):
			_box(props, "Loft_Fourteen_Modular_Form", Vector3(40.95 + float(slot) * 2.1, elevation, -21.1), Vector3(1.12, 0.68, 1.05), mats["gold"] if tier % 2 == 0 else mats["aqua"])
	_text(props, "LOFT  /  14 MODULES  /  7 TIERS", Vector3(42, 9.0, -20.1), 15, Color("ffdda4"))
	_workbench(Vector3(27, 0, -19.7), 9.5, 2.4, mats["carbon"])
	_box(props, "Forge_Control_Screen", Vector3(27, 2.55, -19.7), Vector3(6.4, 1.75, 0.3), mats["smoked_glass"])
	_text(props, "E  /  RUN THE FORGE", Vector3(27, 2.75, -19.44), 22, Color("ffe3a2"))
	_text(props, "CLEAR ROWS  →  CAST MATERIALS", Vector3(27, 2.16, -19.44), 15, Color("c4f3ed"))
	# Genuine outfeed belt to the workshop, not a decorative isolated cabinet.
	for xx in range(12, 37, 2):
		_box(props, "Foundry_Product_Conveyor", Vector3(float(xx), 0.75, -24.4), Vector3(1.86, 0.28, 2.5), mats["carbon"])
		for zz in [-25.54, -23.26]:
			_box(props, "Conveyor_Rail", Vector3(float(xx), 0.98, zz), Vector3(1.8, 0.12, 0.09), mats["gold"])
	_box(props, "Loft_Exchange_Console", Vector3(11.1, 1.08, -18.8), Vector3(4.4, 2.15, 3.0), mats["black"], true)
	_box(props, "Loft_Exchange_Monitor", Vector3(11.1, 2.91, -18.6), Vector3(4.4, 1.2, 0.2), mats["smoked_glass"])
	_text(props, "LOFT STOCK EXCHANGE", Vector3(11.1, 3.04, -18.47), 18, Color("fff0ce"))
	_text(props, "K / BUILD VISOR CHIP", Vector3(11.1, 2.6, -18.47), 16, Color("9ce6e4"))
	_beam(details, "DigDug_Ore_To_Forge", Vector3(-6, 8.3, 1), Vector3(18, 8.3, -29), 0.08, mats["bronze"])
	_beam(details, "Asteroids_Salvage_To_Forge", Vector3(6, 8.3, 19), Vector3(22, 8.3, -29), 0.08, mats["blue"])
	_beam(details, "Forge_Output_To_Loft", Vector3(27, 8.3, -24), Vector3(6, 8.3, -18), 0.12, mats["gold"])
	_text(props, "RECOVERED STOCK  →  TETROMINO PACKING  →  MODULAR COMPONENTS", Vector3(27, 11.7, -31.8), 16, Color("ffe4a4"))
	output_display = Node3D.new()
	output_display.name = "Real_Output_Goods_From_Foundry_Runs"
	props.add_child(output_display)
	output_counter = _text(props, "PACKED 0 / BLANKS 0", Vector3(18.0, 3.1, -22.3), 18, Color("fce2aa"))
	_lamp(Vector3(29.5, 12, -29), Color("ffb475"), 3.0, 18.0)

func _refresh_workshop_stock() -> void:
	if output_counter != null:
		output_counter.text = "PACKED %d / BLANKS %d" % [inventory.amount("packed_block"), inventory.amount("forged_blank")]
	if output_display != null:
		for child in output_display.get_children():
			child.queue_free()
		for i in range(min(15, inventory.amount("packed_block"))):
			var xx := 15.0 + float(i % 5) * 1.04
			var yy := 1.29 + float(i / 5) * 0.59
			_box(output_display, "Finished_Packed_Module", Vector3(xx, yy, -24.35), Vector3(0.89, 0.56, 0.94), mats["gold"])
		for i in range(min(5, inventory.amount("forged_blank"))):
			_box(output_display, "Finished_Forged_Blank", Vector3(20.2 + float(i) * 0.83, 1.31, -24.3), Vector3(0.52, 0.60, 0.72), mats["ceramic"])

func _open_foundry() -> void:
	if active_foundry != null:
		return
	player.input_locked = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	foundry_layer = CanvasLayer.new()
	foundry_layer.name = "Forge_Station_Operator"
	foundry_layer.layer = 10
	add_child(foundry_layer)
	active_foundry = preload("res://theme_foundry/forge_foundry.tscn").instantiate() as MinigameInterface
	foundry_layer.add_child(active_foundry)
	active_foundry.minigame_finished.connect(_on_foundry_finished)
	active_foundry.start(inventory.get_foundry_config())

func _on_foundry_finished(receipt: Dictionary) -> void:
	var accepted := inventory.deposit_from_minigame(receipt)
	result_label.text = "FORGE / " + str(receipt.get("reason", "RETURNED"))
	if accepted:
		result_label.text += " / %d PACKED / %d BLANKS / %d SCRAP DEPOSITED" % [
			int(receipt["materials_produced"].get("packed_block", 0)),
			int(receipt["materials_produced"].get("forged_blank", 0)),
			int(receipt["materials_produced"].get("scrap", 0))]
	else:
		result_label.text = "FORGE RECEIPT REJECTED / MATERIALS NOT AVAILABLE"
	foundry_layer.queue_free()
	active_foundry = null
	foundry_layer = null
	player.input_locked = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _build_player_and_hud() -> void:
	player = WorkshopExplorer.new()
	player.position = Vector3(0, 0.45, 31.8)
	player.rotation.y = 0.0
	add_child(player)
	var ui := CanvasLayer.new()
	ui.name = "Workshop_Explorer_HUD"
	add_child(ui)
	player.ui_layer = ui
	var top := PanelContainer.new()
	top.name = "LocationStrip"
	top.position = Vector2(22, 18)
	top.custom_minimum_size = Vector2(435, 112)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.03, 0.08, 0.12, 0.87)
	bg.border_color = Color("bda36d")
	bg.set_border_width_all(1)
	bg.set_corner_radius_all(6)
	top.add_theme_stylebox_override("panel", bg)
	ui.add_child(top)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 5)
	top.add_child(v)
	var title := Label.new()
	title.text = "GERTECH   /   AQUA WORKSHOP"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("e3f1f2"))
	v.add_child(title)
	location_label = Label.new()
	location_label.text = "LOCATION  /  ARRIVAL GALLERY"
	location_label.add_theme_font_size_override("font_size", 17)
	location_label.add_theme_color_override("font_color", Color("f7d8a4"))
	v.add_child(location_label)
	pulse_label = Label.new()
	pulse_label.text = "AQUA  •  GERTECH  •  WALKTHROUGH"
	pulse_label.add_theme_font_size_override("font_size", 13)
	pulse_label.add_theme_color_override("font_color", Color("8ecbd2"))
	v.add_child(pulse_label)
	var help := PanelContainer.new()
	help.name = "Controls"
	help.anchor_left = 1.0
	help.anchor_right = 1.0
	help.offset_left = -430.0
	help.offset_right = -18.0
	help.offset_top = 18
	help.custom_minimum_size = Vector2(410, 75)
	var hb := StyleBoxFlat.new()
	hb.bg_color = Color(0.02, 0.08, 0.12, 0.84)
	hb.border_color = Color("6b98a2")
	hb.set_border_width_all(1)
	hb.set_corner_radius_all(5)
	help.add_theme_stylebox_override("panel", hb)
	ui.add_child(help)
	var commands := Label.new()
	commands.text = "WASD move • MOUSE look • N free camera • H HUD\nG expand lattice • B place forged blocks • V 2D links • T 3D cells\nE forge • K upgrade • ESC cursor • Controller: sticks / A jump"
	commands.add_theme_font_size_override("font_size", 13)
	commands.add_theme_color_override("font_color", Color("cfe7ec"))
	help.add_child(commands)
	var bottom := PanelContainer.new()
	bottom.name = "Shared_Inventory_And_Material_Feed"
	bottom.anchor_top = 1.0
	bottom.anchor_bottom = 1.0
	bottom.offset_left = 20
	bottom.offset_right = 1345
	bottom.offset_top = -142
	bottom.offset_bottom = -18
	var bs := StyleBoxFlat.new()
	bs.bg_color = Color(0.03, 0.08, 0.11, 0.9)
	bs.border_color = Color("bda36d")
	bs.set_border_width_all(1)
	bottom.add_theme_stylebox_override("panel", bs)
	ui.add_child(bottom)
	var stack := VBoxContainer.new()
	bottom.add_child(stack)
	interaction_label = Label.new()
	interaction_label.text = ""
	interaction_label.add_theme_font_size_override("font_size", 18)
	interaction_label.add_theme_color_override("font_color", Color("ffdc9c"))
	stack.add_child(interaction_label)
	inventory_label = Label.new()
	inventory_label.add_theme_font_size_override("font_size", 17)
	inventory_label.add_theme_color_override("font_color", Color("d7e9e6"))
	stack.add_child(inventory_label)
	worldseed_label = Label.new()
	worldseed_label.add_theme_font_size_override("font_size", 14)
	worldseed_label.add_theme_color_override("font_color", Color("e5d39a"))
	stack.add_child(worldseed_label)
	result_label = Label.new()
	result_label.text = "SHARED WORKSHOP INVENTORY / STAGING STOCK ON HAND / EXPLORE THE LOFT"
	result_label.add_theme_font_size_override("font_size", 14)
	result_label.add_theme_color_override("font_color", Color("9cd6dd"))
	stack.add_child(result_label)
