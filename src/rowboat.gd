class_name Rowboat
extends RigidBody3D

@export var row_power : float = 10.0
@export var pontoons : Array[Pontoon]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("row"):
		apply_central_impulse(Vector3.FORWARD * row_power + (Vector3.LEFT * randf_range(-1.0, 1.0)))

func _process(delta: float) -> void:
	#print_debug(linear_velocity.y)
	pass
