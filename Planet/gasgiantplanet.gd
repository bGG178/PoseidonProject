extends Node3D

# Degrees per second
const ROTATION_SPEED_DEG := 4.0

func _process(delta: float) -> void:
	# Rotate 1 degree per second around the Y-axis
	var rotation_radians := deg_to_rad(ROTATION_SPEED_DEG) * delta
	rotate_y(rotation_radians)
