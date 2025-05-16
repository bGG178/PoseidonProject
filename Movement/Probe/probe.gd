extends CharacterBody3D

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

@onready var camera := $Camera #Set camera to the Camera node inside Probe Scene

#On scene load get rid of the mouse cursor
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#On input (event) do following
func _unhandled_input(event: InputEvent) -> void:
	#If the event is a mouse movement
	if event is InputEventMouseMotion:
		# Yaw: Rotate around local up (yaw stays intuitive even when rolled)
		rotate_object_local(Vector3.UP, -event.relative.x * MOUSE_SENSITIVITY)

		# Pitch: Rotate around camera's local X axis
		rotate_object_local(Vector3.RIGHT, event.relative.y * MOUSE_SENSITIVITY)

		# Clamp pitch to avoid flipping over (lock between -89° and 89°)
		var pitch_angle = camera.rotation_degrees.x
		pitch_angle = clamp(pitch_angle, -89, 89)
		camera.rotation_degrees.x = pitch_angle

#Every frame (delta) update
func _physics_process(delta: float) -> void:
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
		velocity += direction * ACCELERATION * delta
		velocity = velocity.limit_length(MAX_SPEED)
	else:
		velocity = velocity.move_toward(Vector3.ZERO, DAMPING * delta)
		
	# Apply roll from angular velocity (Z-axis only)
	rotate(camera.global_transform.basis.z.normalized(), angular_velocity.z * delta)

	#Update text with current speed magnitude
	$UI/SpeedIndicator.text = str(sqrt(abs(velocity.x)+abs(velocity.y)+abs(velocity.z)))
	
	#apply movement
	move_and_slide()

func _input(event: InputEvent) -> void:
	#Quit game on escape key
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()
		
	#Change between first and 3rd person
	if event is InputEventKey and event.pressed and event.keycode == KEY_C:
		if (camera.position.y >= 0.19) && (camera.position.y < 0.21):
			camera.position = Vector3(0.035,0.991,-2.704)
			camera.rotation = Vector3(deg_to_rad(-15.9), deg_to_rad(-180), 0)
		else:
			camera.position = Vector3(0.035,0.2,0.301)
			camera.rotation = Vector3(0, deg_to_rad(-180), 0)
