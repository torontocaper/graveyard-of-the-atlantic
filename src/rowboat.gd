class_name Rowboat
extends RigidBody3D

@export var row_power : float = 100.0
@export var water : Water

var markers : Array[Marker3D]

@onready var marker_bow: Marker3D = $MarkerBow
@onready var marker_starboard_aft: Marker3D = $MarkerStarboardAft
@onready var marker_port_aft: Marker3D = $MarkerPortAft

func _ready() -> void:
	markers = [
		marker_bow,
		marker_port_aft,
		marker_starboard_aft
	]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("row"):
		apply_central_impulse(Vector3.FORWARD * row_power)
