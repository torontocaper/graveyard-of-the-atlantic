class_name Deformer
extends CharacterBody3D

const MOVE_SPEED : float = 5.0

func _physics_process(delta: float) -> void:
	velocity.x = Input.get_axis("left", "right") * MOVE_SPEED
	velocity.z = Input.get_axis("forward", "reverse") * MOVE_SPEED
	velocity.y = Input.get_axis("down", "up") * MOVE_SPEED
	move_and_slide()
