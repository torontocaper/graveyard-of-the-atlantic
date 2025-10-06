extends CanvasLayer

@onready var speed_label: Label = $Stats/SpeedLabel
@onready var heading_label: Label = $Stats/HeadingLabel
@onready var title_panel: Panel = $TitlePanel
@onready var stats: VBoxContainer = $Stats
@onready var victory_panel: Panel = $VictoryPanel

func _ready() -> void:
	victory_panel.visible = false
	var boat = get_parent().get_node("PlayerBoat3D")
	boat.speed_changed.connect(_on_boat_speed_changed)
	boat.heading_changed.connect(_on_boat_heading_changed)
	boat.crashed.connect(_on_boat_crashed)
	stats.visible = false
	var timer = get_tree().create_timer(4.0)
	await timer.timeout
	stats.visible = true
	title_panel.visible = false

func _on_boat_crashed():
	var death_ui_timer = get_tree().create_timer(2.0)
	await death_ui_timer.timeout
	stats.visible = false
	$DeathPanel.visible = true

func _on_boat_speed_changed(value: float):
	speed_label.text = "Speed: %d" % value

func _on_boat_heading_changed(value: float):
	heading_label.text = "Heading: %d" % value
	
func _on_victory_area_entered(body):
	if body is RigidBody3D:
		victory_panel.visible = true
		var victory_quit_timer = get_tree().create_timer(3.0)
		await victory_quit_timer.timeout
		get_tree().quit()
