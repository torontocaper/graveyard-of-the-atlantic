class_name WaterArea3D
extends Area3D

@onready var water_mesh: WaterMesh = $WaterMesh



func _on_body_entered(body: Node3D) -> void:
	if body is Deformer:
		print_stack()
