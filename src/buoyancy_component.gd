#@tool
class_name BuoyancyComponent
extends Marker3D

#@export_tool_button("Force Update") var force_update : Callable = place_pontoons
#region Constants
#const DEBUG_DRAW_3D = preload("res://addons/debug_draw/debug_draw_3d.tscn")
#endregion


#region Properties
@export var parent : RigidBody3D
@export var pontoons : Array[Pontoon]

var buoyancy_direction : Vector3 = Vector3.UP

var water_area : WaterArea:
	set(value):
		if value:
			water_area = value
			for pontoon in pontoons:
				pontoon.water_area = water_area
			print_debug("Buoyancy component %s has entered water area %s" % [name, water_area.name])
		else:
			water_area = null
#endregion

#region Methods
func _ready() -> void:
	for child_index in get_child_count():
		var pontoon = get_child(child_index) as Pontoon
		pontoons.append(pontoon)
	#debug_draw_3d = DEBUG_DRAW_3D.instantiate()

func _process(delta: float) -> void:
	buoyancy_direction = get_buoyancy_direction()

func get_buoyancy_direction() -> Vector3:
	var a : Vector3 = pontoons[1].global_position - pontoons[0].global_position
	var b : Vector3 = pontoons[2].global_position - pontoons[0].global_position
	var cross : Vector3 = a.cross(b)
	return cross.normalized()
#endregion
