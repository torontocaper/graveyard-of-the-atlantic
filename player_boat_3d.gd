extends RigidBody3D
class_name PlayerBoat3D
## RigidBody3D-based boat controller with thrust, steering that depends on speed,
## simple anisotropic drag, buoyancy, and heading/speed signals.
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
signal heading_changed(value: float)  # 0 = North (+Z), 90 = East (+X), etc.

# -------------------------- Forces ---------------------------
@export_category("Forces")
@export_range(0.0, 1000.0, 0.1) var thrust_force: float = 20.0
@export_range(0.0, 1000.0, 0.1) var turn_torque: float = 10.0

# -------------------------- Steering -------------------------
@export_category("Steering")
@export_range(0.1, 100.0, 0.1) var steering_speed_scale: float = 8.0
@export_range(0.0, 1.0, 0.01) var min_steering_factor: float = 0.2

# -------------------------- Drag -----------------------------
@export_category("Drag")
@export_range(0.0, 10.0, 0.01) var forward_drag: float = 0.3
@export_range(0.0, 10.0, 0.01) var lateral_drag: float = 2.5

# -------------------------- Buoyancy -------------------------
@export_category("Buoyancy")
@export var wave_manager: WaveManager
@export var buoyancy_points: Array[NodePath] = []      # Marker3D children around hull
@export var buoyancy_force: float = 2.0               # force multiplier
@export var water_drag: float = 2.0                    # damping factor

var _markers: Array[Marker3D] = []

# -------------------------- Telemetry ------------------------
@export_category("Signals")
@export var emit_epsilon_speed: float = 0.05
@export var emit_epsilon_heading: float = 0.5

const UP := Vector3.UP
const ZERO := Vector3.ZERO

var _last_emitted_speed := -1.0
var _last_emitted_heading := -1.0

func _ready() -> void:
	# Cache buoyancy markers
	for path in buoyancy_points:
		var m = get_node_or_null(path)
		if m:
			_markers.append(m)

func _physics_process(_delta: float) -> void:
	# -------- Buoyancy --------
	for marker in _markers:
		var pos = marker.global_transform.origin
		var rel_pos = pos - global_transform.origin
		var water_y = wave_manager.get_wave_height(pos.x, pos.z)
		if pos.y < water_y:
			var depth = water_y - pos.y
			var force = UP * depth * buoyancy_force
			apply_force(force, rel_pos)

			# Calculate velocity at this marker
			var vel = linear_velocity + angular_velocity.cross(rel_pos)

			# Water damping proportional to velocity & depth
			var damping = -vel * water_drag * depth
			apply_force(damping, rel_pos)


	# Add damping for stability
	apply_central_force(-linear_velocity * water_drag)
	apply_torque(-angular_velocity * water_drag * 0.2)

	# -------- Local axes (forward = -Z, right = +X) --------
	var local_basis := transform.basis
	var fwd: Vector3   = -local_basis.z
	var right: Vector3 =  local_basis.x

	# -------- Input --------
	var throttle := Input.get_axis("reverse", "forward")
	var steer    := Input.get_axis("left", "right")

	# -------- Thrust --------
	if throttle != 0.0:
		apply_central_force(fwd * (throttle * thrust_force))

	# -------- Steering --------
	var speed_along_fwd := linear_velocity.dot(fwd)
	var steering_factor : float = clamp(abs(speed_along_fwd) / steering_speed_scale, min_steering_factor, 1.0)
	var direction_sign : float = sign(speed_along_fwd) if abs(speed_along_fwd) > 0.05 else 1.0
	apply_torque(UP * (-steer * turn_torque * steering_factor * direction_sign))

	# -------- Planar anisotropic drag (XZ only) --------
	var v_fwd := linear_velocity.dot(fwd)
	var v_lat := linear_velocity.dot(right)
	var drag  := fwd * (-v_fwd * forward_drag) + right * (-v_lat * lateral_drag)
	apply_central_force(drag)

	# -------- Telemetry --------
	var speed := linear_velocity.length()
	var flat_fwd := Vector3(fwd.x, 0.0, fwd.z)
	if flat_fwd.length_squared() > 0.000001:
		flat_fwd = flat_fwd.normalized()
	else:
		flat_fwd = Vector3.FORWARD

	var heading_radians := atan2(flat_fwd.x, -flat_fwd.z)
	var compass_heading := fposmod(rad_to_deg(heading_radians), 360.0)

	_emit_speed_if_changed(speed)
	_emit_heading_if_changed(compass_heading)

# -------------------------- Helpers --------------------------
func _emit_speed_if_changed(speed: float) -> void:
	if _last_emitted_speed < 0.0 or abs(speed - _last_emitted_speed) >= emit_epsilon_speed:
		_last_emitted_speed = speed
		emit_signal("speed_changed", speed)

func _emit_heading_if_changed(heading_deg: float) -> void:
	if _last_emitted_heading < 0.0 or abs(heading_deg - _last_emitted_heading) >= emit_epsilon_heading:
		_last_emitted_heading = heading_deg
		emit_signal("heading_changed", heading_deg)
