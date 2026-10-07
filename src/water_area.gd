@tool
class_name WaterArea
extends Area3D
## [Area3D] that defines a body of water, including the space above and below it
##
## Used for detecting when physics bodies have entered the area

@export_tool_button("Force Update") var force_update : Callable = update_water_properties

@export_group("Water Plane", "water_plane_")
@export var water_plane_size : Vector2 = Vector2(200, 200) ## Size of the [WaterPlane] in metres
@export var water_plane_resolution : Vector2i = Vector2i(100, 100) ## Number of subdivisions in the [WaterPlane]
@export var water_plane_jitter : float = 0.1 ## Amount of randomness applied to each vertex in the [WaterPlane]
@export var water_plane_base_color : Color = Color.MIDNIGHT_BLUE ## Base color of the [WaterPlane]

@export_group("Forces", "force_")
@export var force_multiplier_buoyancy : float = 200.0
@export var force_multiplier_drag : float = 20.0

@onready var water_plane: WaterPlane = $WaterPlane

func _ready() -> void:
	water_plane.water_properties = {
		"water_size" = water_plane_size,
		"water_resolution" = water_plane_resolution,
		"water_jitter" = water_plane_jitter,
		"water_base_color" = water_plane_base_color,
	}
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

func update_water_properties() -> void:
	water_plane.water_properties = {
		"water_size" = water_plane_size,
		"water_resolution" = water_plane_resolution,
		"water_jitter" = water_plane_jitter,
		"water_base_color" = water_plane_base_color,
	}

func get_water_height_at_position(_position_x : float, _position_z : float) -> float:
	var height = 0
	# do some stuff
	return height
