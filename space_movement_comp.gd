extends Node

"""
PROTOTYPE DONE
TODO:
	(DONE) Fix relative W and S movement to Camera position
	(DONE) Fix model attachment to the camera
	(DONE) Fix camera glitching to weird angles
"""

# --- Linear motion constants ---
const MAX_SPEED := 30.0 
const ACCELERATION := 20.0
const DAMPING := 5.0 # Rate at which you slow down

# --- Angular motion constants --- Q and E
const ANGULAR_MAX_SPEED := 2.5  # radians/sec
const ANGULAR_ACCELERATION := 6.0
const ANGULAR_DAMPING := 5.0 # Rate at which you slow down
const MOUSE_SENSITIVITY := 0.003

# --- Rotation state --- Gets updated with angular motion changes
var angular_velocity := Vector3.ZERO  # x: pitch, y: yaw, z: roll

#Finds parent camera scene for component
func _find_camera(node: Node) -> Camera3D:
	if node is Camera3D:
		return node
	for child in node.get_children():
		var cam = _find_camera(child)
		if cam:
			return cam
	return null

@onready var char3d := get_parent().get_parent() as CharacterBody3D
@onready var camera := _find_camera(char3d)

#On scene load get rid of the mouse cursor
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

#On input (event) do following
func _unhandled_input(event: InputEvent) -> void:
	if camera.current == true:
		#If the event is a mouse movement
		if event is InputEventMouseMotion:
			# Yaw: Rotate around local up (yaw stays intuitive even when rolled)
			char3d.rotate_object_local(Vector3.UP, -event.relative.x * MOUSE_SENSITIVITY)

			# Pitch: Rotate around camera's local X axis
			char3d.rotate_object_local(Vector3.RIGHT, event.relative.y * MOUSE_SENSITIVITY)

			# Clamp pitch to avoid flipping over (lock between -89° and 89°)
			var pitch_angle = camera.rotation_degrees.x
			pitch_angle = clamp(pitch_angle, -89, 89)
			camera.rotation_degrees.x = pitch_angle

#Every frame (delta) update
func _physics_process(delta: float) -> void:
	if camera.current == true:
		#Updated with direction of movement
		var input_dir: Vector3 = Vector3.ZERO

		# --- Rotation Input ---
		if Input.is_key_pressed(KEY_E):
			angular_velocity.z -= ANGULAR_ACCELERATION * delta
		if Input.is_key_pressed(KEY_Q):
			angular_velocity.z += ANGULAR_ACCELERATION * delta

		# Clamp angular velocity
		angular_velocity = angular_velocity.clamp(
			Vector3(-ANGULAR_MAX_SPEED, -ANGULAR_MAX_SPEED, -ANGULAR_MAX_SPEED),
			Vector3(ANGULAR_MAX_SPEED, ANGULAR_MAX_SPEED, ANGULAR_MAX_SPEED)
		)

		# Dampen angular velocity
		angular_velocity = angular_velocity.move_toward(Vector3.ZERO, ANGULAR_DAMPING * delta)

		# --- Movement Input ---
		if Input.is_key_pressed(KEY_W):
			input_dir.z += 1.0
		if Input.is_key_pressed(KEY_S):
			input_dir.z -= 1.0
		if Input.is_key_pressed(KEY_A):
			input_dir.x -= 1.0
		if Input.is_key_pressed(KEY_D):
			input_dir.x += 1.0
		if Input.is_key_pressed(KEY_SHIFT):
			input_dir.y += 1.0
		if Input.is_key_pressed(KEY_CTRL):
			input_dir.y -= 1.0

		# Sets up camera relative movement controls
		var camera_basis: Basis = camera.global_transform.basis
		var direction: Vector3 = (
			-camera_basis.z * input_dir.z +
			camera_basis.x * input_dir.x +
			camera_basis.y * input_dir.y
		).normalized()

		#idk how this works rn ill be real
		if direction != Vector3.ZERO:
			char3d.velocity += direction * ACCELERATION * delta
			char3d.velocity = char3d.velocity.limit_length(MAX_SPEED)
		else:
			char3d.velocity = char3d.velocity.move_toward(Vector3.ZERO, DAMPING * delta)
			
		# Apply roll from angular velocity (Z-axis only)
		char3d.rotate(camera.global_transform.basis.z.normalized(), angular_velocity.z * delta)

		
		
		#apply movement
		char3d.move_and_slide()
