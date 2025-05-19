extends Node

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002

#Finds parent camera scene for component
func _find_camera(node: Node) -> Camera3D:
	if node is Camera3D:
		return node
	for child in node.get_children():
		var cam = _find_camera(child)
		if cam:
			return cam
	return null
	
#Finds parent head scene for component
func _find_head(node: Node) -> Node3D:
	if node.name == "Head" and node is Node3D:
		return node
	for child in node.get_children():
		var head = _find_head(child)
		if head:
			return head
	return null


@onready var char3d = get_parent().get_parent() as CharacterBody3D
@onready var head = _find_head(char3d)
@onready var camera = _find_camera(char3d)

func _ready():
	print(char3d)
	print(head)
	print(camera)


func _unhandled_input(event: InputEvent) -> void:
	if camera.current == true:
		if event is InputEventMouseMotion:
			# Horizontal rotation (yaw)
			char3d.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)

			# Vertical rotation (pitch)
			var pitch_change = -event.relative.y * MOUSE_SENSITIVITY
			head.rotate_x(pitch_change)

			# Clamp pitch to prevent flipping
			var rotation = head.rotation_degrees
			rotation.x = clamp(rotation.x, -80, 80)
			head.rotation_degrees = rotation

func _physics_process(delta):
	if camera.current == true:
		# Add the gravity.
		if not char3d.is_on_floor():
			char3d.velocity += char3d.get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and char3d.is_on_floor():
			char3d.velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("A", "D", "W", "S")
		var direction = (char3d.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			char3d.velocity.x = direction.x * SPEED
			char3d.velocity.z = direction.z * SPEED
		else:
			char3d.velocity.x = move_toward(char3d.velocity.x, 0, SPEED)
			char3d.velocity.z = move_toward(char3d.velocity.z, 0, SPEED)

		char3d.move_and_slide()
