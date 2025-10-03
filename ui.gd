extends CanvasLayer

@onready var speed_label: Label = $VBoxContainer/SpeedLabel
@onready var heading_label: Label = $VBoxContainer/HeadingLabel

func _ready() -> void:
	var boat = get_parent().get_node("PlayerBoat3D")
	boat.speed_changed.connect(_on_boat_speed_changed)
	boat.heading_changed.connect(_on_boat_heading_changed)

func _on_boat_speed_changed(value: float):
	speed_label.text = "Speed: %d" % value

func _on_boat_heading_changed(value: float):
	heading_label.text = "Heading: %d" % value
