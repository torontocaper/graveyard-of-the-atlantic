class_name Rowboat
extends FloatableBody

const ROW_POWER : float = 100.0

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("row"):
		#apply_central_impulse(Vector3.FORWARD * row_power + (Vector3.LEFT * randf_range(-1.0, 1.0)))

func _physics_process(delta: float) -> void:
	super(delta)
	if Input.is_action_pressed("row"):
		apply_central_force(Vector3.FORWARD * ROW_POWER * delta)
