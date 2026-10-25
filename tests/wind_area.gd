@tool
class_name WindArea
extends Area3D

@export_tool_button("Force update") var force_update_action = force_update
@export var wind_direction : Vector3 = Vector3.FORWARD

@onready var wind_arrow: Node3D = $WindArrow

func force_update() -> void:
	wind_arrow.look_at(wind_direction)

func _ready() -> void:
	force_update()
	wind_source_path = "WindArrow"

#func _physics_process(delta: float) -> void:
	#wind_direction = -wind_arrow.transform.basis.z

func _on_body_entered(body: Node3D) -> void:
	if body is Raft:
		body.wind_area = self
