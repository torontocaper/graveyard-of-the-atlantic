#@tool
class_name Pontoon
extends Marker3D

signal emerged
signal submerged

var is_submerged : bool = false:
	set(value):
		if is_submerged == value:
			return
		else:
			is_submerged = value
			match is_submerged:
				true:
					submerged.emit()
				false:
					emerged.emit()

var depth : float:
	set(value):
		if value >= 0.0:
			depth = value
			is_submerged = true
		else:
			depth = 0.0
			is_submerged = false


var water_area : WaterArea
var water_height : float = 0.0

func update_depth() -> void:
	water_height = water_area.get_water_height_at_position(global_position.x, global_position.z)
	depth = water_height - global_position.y

func _physics_process(_delta: float) -> void:
	if water_area:
		update_depth()
