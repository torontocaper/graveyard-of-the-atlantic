extends CanvasLayer

@onready var speed_label: Label = $Stats/SpeedLabel
@onready var heading_label: Label = $Stats/HeadingLabel
@onready var title_panel: Panel = $TitlePanel
@onready var stats: VBoxContainer = $Stats

func _ready() -> void:
	var boat = get_parent().get_node("PlayerBoat3D")
	boat.speed_changed.connect(_on_boat_speed_changed)
	boat.heading_changed.connect(_on_boat_heading_changed)
	stats.visible = false
	var timer = get_tree().create_timer(3.0)
	await timer.timeout
	stats.visible = true
	title_panel.visible = false

func _on_boat_speed_changed(value: float):
	speed_label.text = "Speed: %d" % value

func _on_boat_heading_changed(value: float):
	heading_label.text = "Heading: %d" % value
