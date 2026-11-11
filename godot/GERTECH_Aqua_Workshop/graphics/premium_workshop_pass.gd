extends RefCounted
class_name GertechPremiumWorkshopPass

# GERTECH / AQUA visual-only architectural finishing pass.
# Does not modify WorldSeed, stock, foundry, controls, physics, or interfaces.
# Decorative edges are deliberately non-functional; authoritative ports live in WorldSeed.

static func _box(parent: Node3D, name_tag: String, p: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = name_tag
	var m := BoxMesh.new()
	m.size = size
	n.mesh = m
	n.material_override = mat
	n.position = p
	parent.add_child(n)
	return n

static func _cylinder(parent: Node3D, name_tag: String, p: Vector3, radius: float, height: float, mat: Material, sides: int = 20) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = name_tag
	var m := CylinderMesh.new()
	m.top_radius = radius
	m.bottom_radius = radius
	m.height = height
	m.radial_segments = sides
	n.mesh = m
	n.material_override = mat
	n.position = p
	parent.add_child(n)
	return n

static func _beam(parent: Node3D, name_tag: String, a: Vector3, b: Vector3, radius: float, mat: Material, sides: int = 9) -> void:
	var vec := b - a
	if vec.length() <= 0.001:
		return
	var node := _cylinder(parent, name_tag, (a + b) * 0.5, radius, vec.length(), mat, sides)
	node.quaternion = Quaternion(Vector3.UP, vec.normalized())

static func _torus(parent: Node3D, name_tag: String, p: Vector3, radius: float, tube: float, mat: Material, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = name_tag
	var m := TorusMesh.new()
	m.inner_radius = radius - tube
	m.outer_radius = radius + tube
	m.rings = 40
	m.ring_segments = 12
	n.mesh = m
	n.material_override = mat
	n.position = p
	n.rotation_degrees = rot
	parent.add_child(n)
	return n

static func _glow_light(parent: Node3D, p: Vector3, c: Color, power: float, reach: float) -> void:
	var light := OmniLight3D.new()
	light.name = "Soft_Workshop_Fill"
	light.position = p
	light.light_color = c
	light.light_energy = power
	light.omni_range = reach
	light.shadow_enabled = false
	parent.add_child(light)

static func _mat(hex: String, metallic: float, roughness: float, emission_hex: String = "", emission_energy: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(hex)
	mat.metallic = metallic
	mat.roughness = roughness
	if emission_energy > 0.0:
		mat.emission_enabled = true
		mat.emission = Color(emission_hex)
		mat.emission_energy_multiplier = emission_energy
	return mat

static func _shared_bolts(parent: Node3D, name_tag: String, positions: Array[Vector3], mat: Material, bolt_radius: float = 0.06) -> void:
	if positions.is_empty():
		return
	var mesh := CylinderMesh.new()
	mesh.top_radius = bolt_radius
	mesh.bottom_radius = bolt_radius
	mesh.height = 0.055
	mesh.radial_segments = 8
	mesh.material = mat
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = positions.size()
	for i in range(positions.size()):
		mm.set_instance_transform(i, Transform3D(Basis.IDENTITY, positions[i]))
	var n := MultiMeshInstance3D.new()
	n.name = name_tag + "_Batched"
	n.multimesh = mm
	parent.add_child(n)

static func _deck_plate(parent: Node3D, center: Vector3, span_x: float, span_z: float, mats: Dictionary) -> void:
	# Raised plates and inner gaskets are decorative: walk collision is unchanged.
	_box(parent, "Machined_Deck_Plate", center + Vector3(0, 0.035, 0), Vector3(span_x, 0.042, span_z), mats["floor_alt"])
	for sign in [-1.0, 1.0]:
		_box(parent, "Deck_Plate_Gasket", center + Vector3(sign * (span_x * 0.5 - 0.13), 0.063, 0), Vector3(0.035, 0.021, span_z - 0.12), mats["bronze"])
	for sign in [-1.0, 1.0]:
		_box(parent, "Deck_Transverse_Gasket", center + Vector3(0, 0.064, sign * (span_z * 0.5 - 0.13)), Vector3(span_x - 0.1, 0.020, 0.035), mats["bronze"])

static func _pressure_glass_details(parent: Node3D, mats: Dictionary) -> void:
	# North-facing thick observation glass; added frames are on the existing wall.
	for x in range(-43, 46, 8):
		var xx := float(x)
		_box(parent, "Pressure_Glass_Secondary_Gasket", Vector3(xx, 7.45, -37.68), Vector3(0.73, 11.65, 0.10), mats["graphite"])
		_box(parent, "Gold_Pressure_Frame_Leaf", Vector3(xx, 7.4, -37.59), Vector3(0.16, 11.40, 0.09), mats["gold"])
		for y in [2.3, 5.1, 8.0, 10.8, 12.2]:
			var bolt_mesh := _cylinder(parent, "Window_Steel_Rivet", Vector3(xx, y, -37.47), 0.115, 0.11, mats["pewter"], 12)
			bolt_mesh.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	for y in [2.35, 12.25]:
		_box(parent, "Panoramic_Gold_Glass_Rail", Vector3(0, y, -37.58), Vector3(94.6, 0.10, 0.12), mats["gold"])
		_box(parent, "Glass_Black_Gasket", Vector3(0, y + 0.11, -37.72), Vector3(94.6, 0.08, 0.12), mats["graphite"])
	for x in range(-42, 43, 8):
		var xx := float(x)
		_box(parent, "Viewport_Low_Service_Plate", Vector3(xx + 3.6, 1.70, -37.7), Vector3(6.8, 0.42, 0.25), mats["pewter"])
		_box(parent, "Viewport_Low_Gold_Inlay", Vector3(xx + 3.6, 1.73, -37.53), Vector3(5.6, 0.045, 0.05), mats["gold"])

static func _ceiling_and_arches(parent: Node3D, mats: Dictionary) -> void:
	# Faceted truss treatment, repeated real beams and recessed practical strips.
	for z in range(-31, 36, 9):
		var zz := float(z)
		for x in range(-42, 43, 14):
			var xx := float(x)
			_beam(parent, "Gold_Truss_Diagonal_A", Vector3(xx - 6.6, 14.60, zz - 4.25), Vector3(xx, 15.15, zz + 4.25), 0.067, mats["gold"], 8)
			_beam(parent, "Gold_Truss_Diagonal_B", Vector3(xx + 6.6, 14.60, zz - 4.25), Vector3(xx, 15.15, zz + 4.25), 0.067, mats["gold"], 8)
			_box(parent, "Truss_Receiver_Block", Vector3(xx, 14.72, zz), Vector3(0.53, 0.32, 0.42), mats["black"])
			_box(parent, "Inset_Diffuser", Vector3(xx, 14.46, zz), Vector3(2.1, 0.035, 0.48), mats["white_light"])
	for z in [5.5, 20.5, -14.0]:
		for side in [-1.0, 1.0]:
			var x: float = side * 6.27
			for h in range(2, 13, 2):
				var collar_mesh := _cylinder(parent, "Arch_Machined_Clamping_Collar", Vector3(x, float(h), z + 0.50), 0.20, 0.12, mats["gold"], 10)
				collar_mesh.rotation_degrees = Vector3(90.0, 0.0, 0.0)
			_box(parent, "Arch_Vertical_Illuminated_Inset", Vector3(x + side * 0.25, 6.8, z), Vector3(0.055, 9.8, 0.25), mats["aqua"])
		_box(parent, "Arch_Header_Metal_Fillet", Vector3(0, 12.78, z + 0.52), Vector3(11.8, 0.13, 0.13), mats["gold"])

static func _promenade(parent: Node3D, mats: Dictionary) -> void:
	# Strong spatial wayfinding cues; no invented station names or UI controls.
	for side in [-1.0, 1.0]:
		var x := 7.1 * side
		for z in range(-32, 33, 4):
			var zz := float(z)
			_box(parent, "Promenade_Gold_Inlay", Vector3(x, 0.082, zz), Vector3(0.065, 0.016, 2.70), mats["gold"])
			_box(parent, "Promenade_Glass_Indicator", Vector3(x + 0.25 * side, 0.083, zz), Vector3(0.080, 0.018, 1.25), mats["aqua"])
	for z in [-31, -15, 6, 22]:
		_box(parent, "Promenade_Transverse_Safety_Line", Vector3(0, 0.084, float(z)), Vector3(14.0, 0.019, 0.08), mats["bronze"])
	# Recessed deck plates along edges, never across the center navigation corridor.
	for x in [-42.5, -38.5, 38.5, 42.5]:
		for z in range(-30, 31, 7):
			_deck_plate(parent, Vector3(x, 0, float(z)), 3.0, 4.6, mats)
	# Details are instanced to avoid thousands of draw calls on handheld GPUs.
	var bolts: Array[Vector3] = []
	for x in [-44.0, -38.0, 38.0, 44.0]:
		for z in range(-31, 33, 7):
			for dx in [-1.05, 1.05]:
				for dz in [-1.80, 1.80]:
					bolts.append(Vector3(x + dx, 0.106, float(z) + dz))
	_shared_bolts(parent, "Deck_Captive_Fasteners", bolts, mats["pewter"], 0.061)

static func _overhead_pipes(parent: Node3D, mats: Dictionary) -> void:
	# Physical service plumbing runs through the existing overhead trusses.
	for lane in [-36.0, -33.0, 33.0, 36.0]:
		_beam(parent, "Copper_Utility_Bus", Vector3(lane, 13.75, -34.0), Vector3(lane, 13.75, 35.0), 0.105, mats["bronze"], 12)
		_beam(parent, "Titanium_Utility_Bus", Vector3(lane + 0.5, 13.6, -34.0), Vector3(lane + 0.5, 13.6, 35.0), 0.074, mats["pewter"], 10)
		for z in range(-29, 34, 9):
			var zz := float(z)
			_box(parent, "Utility_Clamp_Bridge", Vector3(lane + 0.25, 13.74, zz), Vector3(0.93, 0.30, 0.27), mats["graphite"])
			var utility_collar := _cylinder(parent, "Utility_Collar", Vector3(lane, 13.75, zz + 0.18), 0.14, 0.23, mats["gold"], 10)
			utility_collar.rotation_degrees = Vector3(90.0, 0.0, 0.0)

static func _station_hardware(parent: Node3D, mats: Dictionary) -> void:
	# Operating machinery gets believable layered housings and visible feed lines.
	# Workbench details are arranged outside station interaction radii and do not collide.
	for center in [Vector3(-27, 0, -32.0), Vector3(27, 0, -1.9), Vector3(-27.0, 0, 8.0)]:
		for side in [-1.0, 1.0]:
			var xx := center.x + 5.9 * side
			var zz := center.z
			_box(parent, "Bench_Tool_Case_Body", Vector3(xx, 1.42, zz - 0.72), Vector3(1.35, 0.43, 0.66), mats["black"])
			_box(parent, "Tool_Case_Brass_Lip", Vector3(xx, 1.68, zz - 0.72), Vector3(1.43, 0.07, 0.72), mats["gold"])
			for i in range(3):
				_box(parent, "Tool_Case_Status_Indicator", Vector3(xx - 0.43 + i * 0.43, 1.68, zz - 0.30), Vector3(0.19, 0.07, 0.12), mats["aqua"] if i == 1 else mats["pewter"])
	# Refine the six visible resin vats without implying a new manufacturing action.
	for idx in range(6):
		var row: int = idx / 3
		var col: int = idx % 3
		var xx := 18.9 + float(col) * 7.3
		var zz := 19.0 - float(row) * 7.25
		for yy in [1.25, 3.0, 5.1]:
			_torus(parent, "Vat_External_Gold_Retention_Ring", Vector3(xx, yy, zz), 2.15, 0.057, mats["gold"])
		for side in range(6):
			var ang: float = TAU * float(side) / 6.0
			var rx := cos(ang) * 2.13
			var rz := sin(ang) * 2.13
			_beam(parent, "Vat_Pressure_Stay", Vector3(xx + rx, 1.32, zz + rz), Vector3(xx + rx, 5.10, zz + rz), 0.045, mats["pewter"], 8)
			_cylinder(parent, "Vat_Stay_Collar", Vector3(xx + rx, 5.15, zz + rz), 0.12, 0.12, mats["gold"], 10)
		for y in [1.35, 5.2]:
			_box(parent, "Vat_Process_Sensor", Vector3(xx, y, zz + 2.11), Vector3(0.52, 0.18, 0.2), mats["black"])
			_box(parent, "Vat_Process_Light", Vector3(xx, y, zz + 2.24), Vector3(0.26, 0.07, 0.04), mats["aqua"])
	# Growth tubes are now framed with mechanical crystal-gold retention hardware.
	for i in range(5):
		var x := -37.0 + float(i) * 4.9
		var z := -24.0 + float(i % 2) * 2.1
		for yy in [1.20, 3.10, 5.60]:
			_torus(parent, "Crystal_Tube_Machined_Rim", Vector3(x, yy, z), 1.57, 0.045, mats["gold"])
		for a in range(4):
			var angle: float = TAU * float(a) / 4.0
			var rx := cos(angle) * 1.56
			var rz := sin(angle) * 1.56
			_beam(parent, "Crystal_Tube_Fixing_Bar", Vector3(x + rx, 1.2, z + rz), Vector3(x + rx, 5.6, z + rz), 0.045, mats["pewter"], 8)
	# Visible metallurgy details on the completed bench row; no new controls.
	for x in [21.4, 25.0, 28.6, 32.2]:
		for z in [-11.6, -7.9]:
			_box(parent, "Machined_Service_Pad", Vector3(x, 0.11, z), Vector3(2.5, 0.08, 2.1), mats["plinth"])
			_box(parent, "Service_Pad_Edge", Vector3(x, 0.168, z - 0.88), Vector3(2.12, 0.035, 0.055), mats["gold"])

static func _fixture(parent: Node3D, p: Vector3, mats: Dictionary, width: float = 4.0) -> void:
	_box(parent, "Recessed_Light_Housing", p, Vector3(width, 0.23, 0.73), mats["graphite"])
	_box(parent, "Light_Reflector_Well", p + Vector3(0.0, -0.09, 0.0), Vector3(width - 0.22, 0.045, 0.45), mats["pewter"])
	_box(parent, "White_Diffuser", p + Vector3(0.0, -0.13, 0.0), Vector3(width - 0.42, 0.028, 0.34), mats["white_light"])
	for sign in [-1.0, 1.0]:
		_box(parent, "Fixture_Machined_End_Cap", p + Vector3(sign * (width * 0.5 - 0.08), -0.035, 0), Vector3(0.15, 0.30, 0.78), mats["gold"])

static func _lighting(parent: Node3D, mats: Dictionary) -> void:
	for x in [-31.0, -17.0, -3.0, 11.0, 25.0, 39.0]:
		for z in [-29.0, -11.0, 7.0, 25.0]:
			_fixture(parent, Vector3(x, 14.47, z), mats, 3.7)
	# Only a few new real lights; all decorative emissive strips are cheap meshes.
	_glow_light(parent, Vector3(-27.0, 8.5, -24.0), Color("6bbde1"), 1.1, 17.0)
	_glow_light(parent, Vector3(27.0, 9.0, 16.0), Color("ffe0a2"), 1.1, 18.0)
	_glow_light(parent, Vector3(2.0, 10.6, -25.5), Color("9a99ea"), 0.85, 17.0)

static func _showcase_source_meshes(parent: Node3D, mats: Dictionary) -> void:
	# Real original 3D GLBs from the owner-supplied 19-mesh component collection.
	# These are display-only and do not register WorldSeed modules or ports.
	var samples: Array[Dictionary] = [
		{"path": "res://assets/gertech_cube/parts/cube_half.glb", "position": Vector3(-11.3, 2.42, 31.2), "scale": 1.08},
		{"path": "res://assets/gertech_cube/parts/manifold.glb", "position": Vector3(10.5, 2.45, 31.2), "scale": 1.10},
		{"path": "res://assets/gertech_cube/parts/conduit_U.glb", "position": Vector3(13.2, 2.12, 31.2), "scale": 1.4},
	]
	for obj in samples:
		var path: String = obj["path"]
		if not ResourceLoader.exists(path):
			continue
		var packed: Resource = load(path)
		if not (packed is PackedScene):
			continue
		var node: Node = (packed as PackedScene).instantiate()
		if not (node is Node3D):
			node.queue_free()
			continue
		var display := Node3D.new()
		display.name = "ORIGINAL_GLB_MESH_VISUAL_ONLY"
		display.position = obj["position"]
		display.scale = Vector3.ONE * float(obj["scale"])
		parent.add_child(display)
		display.add_child(node)
		_cylinder(parent, "Real_Source_Part_Display_Base", display.position - Vector3(0, 0.85, 0), 0.78, 0.17, mats["graphite"], 20)
		_torus(parent, "Source_Part_Base_Accent", display.position - Vector3(0, 0.75, 0), 0.77, 0.04, mats["gold"])

static func _caustics(parent: Node3D) -> void:
	var shader_path := "res://graphics/aqua_caustics.gdshader"
	if not ResourceLoader.exists(shader_path):
		return
	var shader := load(shader_path)
	if not (shader is Shader):
		return
	var material := ShaderMaterial.new()
	material.shader = shader as Shader
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(89.0, 69.0)
	var mi := MeshInstance3D.new()
	mi.name = "Subsea_Caustic_Reflections_VISUAL_ONLY"
	mi.mesh = mesh
	mi.material_override = material
	mi.position = Vector3(0, 0.088, 0)
	parent.add_child(mi)

static func install(workshop: Node3D, props: Node3D, details: Node3D, mats: Dictionary, quality: int = 3) -> void:
	# Quality 0: original workshop visuals. 1: cleaner architecture. 2: high detail.
	# Quality 3: full source-mesh gallery and moving caustics. Gameplay never varies.
	if quality <= 0:
		return
	var premium := Node3D.new()
	premium.name = "GERTECH_Premium_Workshop_Visuals_NO_SIMULATION"
	details.add_child(premium)
	_pressure_glass_details(premium, mats)
	_promenade(premium, mats)
	_lighting(premium, mats)
	if quality >= 2:
		_ceiling_and_arches(premium, mats)
		_overhead_pipes(premium, mats)
		_station_hardware(premium, mats)
	if quality >= 3:
		_showcase_source_meshes(premium, mats)
		_caustics(premium)
