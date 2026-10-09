@tool
class_name BuoyancyComponent
extends Marker3D

#@export_tool_button("Force Update") var force_update : Callable = place_pontoons

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

#func place_pontoons() -> void:
	#for pontoon_index in pontoons.size():
			#pontoons[pontoon_index].position = flotation_points[pontoon_index]
#endregion
