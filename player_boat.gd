extends RigidBody2D

signal speed_changed(value: float)
signal heading_changed(value: float)

@export var thrust_force : float = 50.0
@export var turn_torque : float = 100.0
@export var forward_drag: float = 0.2     # low resistance, keeps coasting
@export var lateral_drag: float = 3.0     # high resistance, prevents endless sideways drift

func _physics_process(_delta: float) -> void:
	var forward = Vector2.RIGHT.rotated(rotation)
	var right = forward.rotated(-PI/2)

	# Inputs
	var thrust = Input.get_axis("reverse", "forward")
	var turn_direction = Input.get_axis("left", "right")

	# Apply thrust and steering torque
	apply_central_force(forward * thrust * thrust_force)
	apply_torque(turn_direction * turn_torque)

	# --- Drag model ---
	var v_fwd = linear_velocity.dot(forward)
	var v_lat = linear_velocity.dot(right)

	# Resist sideways sliding a lot, forward only a little
	var drag_force = forward * (-v_fwd * forward_drag) \
				   + right * (-v_lat * lateral_drag)
	apply_central_force(drag_force)

	# Update UI
	var speed = linear_velocity.length()
	var heading = fposmod(rotation_degrees + 90.0, 360.0)
	emit_signal("speed_changed", speed)
	emit_signal("heading_changed", heading)
