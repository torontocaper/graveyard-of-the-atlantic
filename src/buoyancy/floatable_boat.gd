class_name FloatableBoat
extends FloatableBody

@export var row_power : float = 25.0
@export var turn_power : float = 5.0

#func _physics_process(delta: float) -> void:
	#pass

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if Input.is_action_just_pressed("row"):
		state.linear_velocity = row_power * global_transform.basis.z
	if Input.is_action_just_pressed("left"):
		state.angular_velocity = turn_power * global_transform.basis.y
	if Input.is_action_just_pressed("right"):
		state.angular_velocity = -turn_power * global_transform.basis.y
