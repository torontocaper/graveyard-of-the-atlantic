extends RigidBody3D
class_name PlayerBoat3D
## RigidBody3D-based boat controller with thrust, steering that depends on speed,
## simple anisotropic drag, and heading/speed signals.
##
## INPUT MAP (Project > Input Map):
##   "forward", "reverse", "left", "right"
##
## NOTES:
## - Forward is along local -Z (Godot convention). If your mesh faces +Z, rotate the mesh.
## - Steering flips when moving backwards (like a real rudder/wheel in reverse).
## - Drag is applied only on the XZ plane (no vertical drag here).
## - Signals emit only when values change beyond a small epsilon to prevent spam.

# -------------------------- Signals --------------------------
signal speed_changed(value: float)
signal heading_changed(value: float)  # 0 = North (+Z), 90 = East (+X), 180 = South, 270 = West

# -------------------------- Tuning ---------------------------
@export_category("Forces")
@export_range(0.0, 1000.0, 0.1) var thrust_force: float = 20.0      # N applied along local forward
@export_range(0.0, 1000.0, 0.1) var turn_torque: float = 10.0        # N·m around Y

@export_category("Steering")
@export_range(0.1, 100.0, 0.1) var steering_speed_scale: float = 8.0 # m/s to reach full rudder authority
@export_range(0.0, 1.0, 0.01) var min_steering_factor: float = 0.2    # steering floor at near-zero speed

@export_category("Drag")
@export_range(0.0, 10.0, 0.01) var forward_drag: float = 0.3          # coefficient along forward axis
@export_range(0.0, 10.0, 0.01) var lateral_drag: float = 2.5          # coefficient lateral to forward

@export_category("Signals")
@export var emit_epsilon_speed: float = 0.05      # m/s; min delta to re-emit speed
@export var emit_epsilon_heading: float = 0.5     # degrees; min delta to re-emit heading

# -------------------------- Internals ------------------------
const UP := Vector3.UP
const ZERO := Vector3.ZERO

var _last_emitted_speed := -1.0
var _last_emitted_heading := -1.0

func _physics_process(_delta: float) -> void:
	# -------- Local axes (forward = -Z, right = +X, up = +Y) --------
	# Using basis columns avoids allocating transforms every time.
	var local_basis := transform.basis
	var fwd: Vector3   = -local_basis.z
	var right: Vector3 =  local_basis.x
	# up is constant Vector3.UP, but basis.y kept if you want boat roll/pitch info.

	# -------- Input --------
	var throttle := Input.get_axis("reverse", "forward")  # negative..positive
	var steer    := Input.get_axis("left", "right")       # negative..positive

	# -------- Thrust --------
	# Apply force along the boat's forward axis. Works forward or reverse.
	if throttle != 0.0:
		apply_central_force(fwd * (throttle * thrust_force))

	# -------- Steering authority scales with forward speed --------
	# Positive when moving forward, negative when reversing.
	var speed_along_fwd := linear_velocity.dot(fwd)

	# Steering factor: grows with |forward speed|, clamped to [min, 1].
	var steering_factor : float = clamp(abs(speed_along_fwd) / steering_speed_scale, min_steering_factor, 1.0)

	# Flip steering in reverse so "turn right" while backing steers like a car/boat.
	# When nearly stopped, keep sign = +1 to avoid jittery flips.
	var direction_sign : float = sign(speed_along_fwd) if abs(speed_along_fwd) > 0.05 else 1.0

	# Apply yaw torque around global Y (up).
	apply_torque(UP * (-steer * turn_torque * steering_factor * direction_sign))

	# -------- Planar anisotropic drag (XZ only) --------
	# Decompose velocity into local forward/lateral components and oppose each separately.
	var v_fwd := linear_velocity.dot(fwd)
	var v_lat := linear_velocity.dot(right)
	var drag  := fwd * (-v_fwd * forward_drag) + right * (-v_lat * lateral_drag)
	apply_central_force(drag)

	# -------- Telemetry (speed & compass heading) --------
	var speed := linear_velocity.length()

	# Flatten local forward onto XZ to compute compass heading.
	var flat_fwd := Vector3(fwd.x, 0.0, fwd.z)
	if flat_fwd.length_squared() > 0.000001:
		flat_fwd = flat_fwd.normalized()
	else:
		# If severely tilted or degenerate, fall back to current transform facing.
		flat_fwd = Vector3.FORWARD

	# Convert to compass degrees: 0 = North (+Z), 90 = East (+X), etc.
	var heading_radians := atan2(flat_fwd.x, -flat_fwd.z)
	var compass_heading := fposmod(rad_to_deg(heading_radians), 360.0)

	_emit_speed_if_changed(speed)
	_emit_heading_if_changed(compass_heading)

# --------------------------------------------------------------
#                       Helper methods
# --------------------------------------------------------------

func _emit_speed_if_changed(speed: float) -> void:
	if _last_emitted_speed < 0.0 or abs(speed - _last_emitted_speed) >= emit_epsilon_speed:
		_last_emitted_speed = speed
		emit_signal("speed_changed", speed)

func _emit_heading_if_changed(heading_deg: float) -> void:
	if _last_emitted_heading < 0.0 or abs(heading_deg - _last_emitted_heading) >= emit_epsilon_heading:
		_last_emitted_heading = heading_deg
		emit_signal("heading_changed", heading_deg)
