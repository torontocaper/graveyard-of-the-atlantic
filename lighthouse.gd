@tool
extends StaticBody3D

@export var rotation_speed: float = 25.0  # degrees per second
@onready var light_pivot: Node3D = $LightPivot

func _process(delta: float) -> void:
	light_pivot.rotate_y(deg_to_rad(rotation_speed * delta))
