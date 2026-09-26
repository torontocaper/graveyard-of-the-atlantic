class_name Rowboat
extends RigidBody3D

@export var row_power : float = 100.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("row"):
		apply_central_impulse(Vector3.FORWARD * row_power)
