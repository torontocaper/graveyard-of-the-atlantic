class_name WaterArea
extends Area3D

@export var buoyancy_force_multiplier : float = 200.0
@export var drag_force_multiplier : float = 20.0

@onready var water_plane: WaterPlane = $WaterPlane

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)

func on_body_entered(body : Node3D) -> void:
	print_debug("Water Area %s has detected %s entering" % [name, body.name])
	if body is Rowboat:
		for pontoon in body.pontoons:
			pontoon.water_area = self

func on_body_exited(body : Node3D) -> void:
	print_debug("Water Area %s has detected %s exiting" % [name, body.name])
	if body is Rowboat:
		for pontoon in body.pontoons:
			pontoon.water_area = null
			
func get_water_height_at_position(_position_x : float, _position_z : float) -> float:
	var height = 0
	
	return height
