class_name Pontoon
extends Node3D

signal emerged
signal submerged

@export var parent : RigidBody3D

var is_submerged : bool = false:
	set(value):
		if is_submerged == value:
			return
		else:
			is_submerged = value
			match is_submerged:
				true:
					submerged.emit()
					if parent:
						print_debug("%s has gone under the water at %s m/s" % [name, abs(snapped(parent.linear_velocity.y, 0.001))])
				false:
					emerged.emit()
					if parent:
						print_debug("%s has emerged from the water at %s m/s" % [name, abs(snappedf(parent.linear_velocity.y, 0.001))])

var depth : float
var water_area : WaterArea:
	set(value):
		if value:
			water_area = value
			print_debug("Pontoon %s has entered water area %s" % [name, water_area.name])
		else:
			water_area = null
var water_height : float = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if water_area:
		water_height = water_area.get_water_height_at_position(global_position.x, global_position.z)
		depth = water_height - global_position.y
		if depth >= 0:
			is_submerged = true
		else:
			is_submerged = false
		if is_submerged and parent:
			parent.apply_force(Vector3.UP * depth * water_area.force_multiplier_buoyancy, position)
			parent.apply_force(-parent.linear_velocity * depth * water_area.force_multiplier_drag, position)
