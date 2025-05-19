extends CharacterBody3D

@onready var camera := $ProbeCamera #Set camera to the Camera node inside Probe Scene

func _physics_process(delta):
	pass
	#Update text with current speed magnitude
	#$UI/SpeedIndicator.text = str(sqrt(abs(velocity.x)+abs(velocity.y)+abs(velocity.z)))

func _input(event: InputEvent) -> void:
	if camera.current == true:
		#Change between first and 3rd person
		if event is InputEventKey and event.pressed and event.keycode == KEY_C:
			if (camera.position.y >= 0.19) && (camera.position.y < 0.21):
				camera.position = Vector3(0.035,0.991,-2.704)
				camera.rotation = Vector3(deg_to_rad(-15.9), deg_to_rad(-180), 0)
			else:
				camera.position = Vector3(0.035,0.2,0.301)
				camera.rotation = Vector3(0, deg_to_rad(-180), 0)
				
		if event is InputEventKey and event.pressed and event.keycode == KEY_V:
			camera.current = false
