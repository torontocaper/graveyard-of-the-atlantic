class_name Rowboat
extends FloatableBody

const ROW_POWER : float = 100.0

var thrust_direction : Vector3

#func _unhandled_input(event: InputEvent) -> void:

func _physics_process(delta: float) -> void:
	super(delta)
	thrust_direction = get_thrust_direction()
	if Input.is_action_just_pressed("row"):
		apply_central_impulse(ROW_POWER * thrust_direction)

func get_thrust_direction() -> Vector3:
	return -global_transform.basis.z
