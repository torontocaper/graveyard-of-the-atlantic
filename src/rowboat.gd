class_name Rowboat
extends FloatableBody

const ROW_POWER : float = 10.0

#func _unhandled_input(event: InputEvent) -> void:

func _physics_process(delta: float) -> void:
	super(delta)
	if Input.is_action_just_pressed("row"):
		apply_central_impulse(Vector3.FORWARD * ROW_POWER)
	#if Input.is_action_pressed("row"):
		#apply_central_force(Vector3.FORWARD * ROW_POWER * delta)
