extends CharacterBody3D
class_name WorkshopExplorer

# Navigation only. Gameplay, physics, interaction and inventory are deliberately absent.
const WALK_SPEED := 6.8
const SPRINT_SPEED := 11.0
const FLY_SPEED := 12.0
const LOOK_SENSITIVITY := 0.0018

var fly_mode := false
var input_locked := false
var camera: Camera3D
var camera_pitch := 0.0
var previous_n := false
var previous_h := false
var hud_visible := true
var ui_layer: CanvasLayer

func _ready() -> void:
	name = "Explorer"
	collision_layer = 2
	collision_mask = 1
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.32
	capsule.height = 1.8
	collision.shape = capsule
	collision.position = Vector3(0.0, 0.9, 0.0)
	add_child(collision)
	camera = Camera3D.new()
	camera.name = "Eyes"
	camera.position = Vector3(0.0, 1.64, 0.0)
	camera.fov = 78.0
	camera.current = true
	add_child(camera)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if input_locked:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * LOOK_SENSITIVITY)
		camera_pitch = clamp(camera_pitch - event.relative.y * LOOK_SENSITIVITY, -1.5, 1.5)
		camera.rotation.x = camera_pitch
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if event.keycode == KEY_N:
			fly_mode = not fly_mode
			velocity = Vector3.ZERO
		if event.keycode == KEY_H and ui_layer != null:
			hud_visible = not hud_visible
			ui_layer.visible = hud_visible

func _physics_process(delta: float) -> void:
	if input_locked:
		velocity = Vector3.ZERO
		return
	var walk := Vector2.ZERO
	if Input.is_key_pressed(KEY_A): walk.x -= 1.0
	if Input.is_key_pressed(KEY_D): walk.x += 1.0
	if Input.is_key_pressed(KEY_W): walk.y -= 1.0
	if Input.is_key_pressed(KEY_S): walk.y += 1.0
	var joy_x := Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	var joy_y := Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	if abs(joy_x) > 0.16: walk.x += joy_x
	if abs(joy_y) > 0.16: walk.y += joy_y
	walk = walk.limit_length(1.0)

	var look_x := Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var look_y := Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	if abs(look_x) > 0.17: rotate_y(-look_x * delta * 2.3)
	if abs(look_y) > 0.17:
		camera_pitch = clamp(camera_pitch - look_y * delta * 2.3, -1.5, 1.5)
		camera.rotation.x = camera_pitch

	var movement := (global_transform.basis * Vector3(walk.x, 0.0, walk.y)).normalized()
	var moving_fast := Input.is_key_pressed(KEY_SHIFT) or Input.is_joy_button_pressed(0, JOY_BUTTON_LEFT_STICK)
	if fly_mode:
		var vertical := 0.0
		if Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0, JOY_BUTTON_A): vertical += 1.0
		if Input.is_key_pressed(KEY_CTRL) or Input.is_joy_button_pressed(0, JOY_BUTTON_B): vertical -= 1.0
		velocity = (movement + Vector3.UP * vertical).normalized() * (FLY_SPEED * (1.8 if moving_fast else 1.0))
		global_position += velocity * delta
	else:
		var speed := SPRINT_SPEED if moving_fast else WALK_SPEED
		velocity.x = movement.x * speed
		velocity.z = movement.z * speed
		if is_on_floor():
			velocity.y = -0.25
			if Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0, JOY_BUTTON_A):
				velocity.y = 5.3
		else:
			velocity.y -= 12.0 * delta
		move_and_slide()
	if global_position.y < -6.0:
		global_position = Vector3(0.0, 0.4, 18.0)
		velocity = Vector3.ZERO
