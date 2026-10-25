class_name WindArea
extends Area3D

var wind_direction : Vector3

@onready var wind_arrow: Node3D = $WindArrow

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	wind_direction = -wind_arrow.transform.basis.z

func _on_body_entered(body: Node3D) -> void:
	if body is Raft:
		body.wind_area = self
