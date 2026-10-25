class_name Raft
extends RigidBody3D

var wind_area : WindArea:
	set(value):
		wind_area = value
		wind_direction = wind_area.wind_direction
		print_debug("Wind direction: %s" % wind_direction)

var wind_direction : Vector3
var wind_force : Vector3 = Vector3.ZERO

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if wind_area:
		wind_direction = wind_area.wind_direction
		wind_force = wind_area.wind_force_magnitude * wind_direction
	apply_central_force(wind_force * delta)
