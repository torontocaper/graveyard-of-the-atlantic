extends CanvasLayer

@onready var speed_label: Label = $Stats/SpeedLabel
@onready var heading_label: Label = $Stats/HeadingLabel
@onready var title_panel: Panel = $TitlePanel
@onready var stats: VBoxContainer = $Stats
@onready var victory_panel: Panel = $VictoryPanel
@onready var victory_label: Label = $VictoryPanel/VictoryLabel
@onready var death_panel: Panel = $DeathPanel

var time : float = 0.0

func _ready() -> void:
	death_panel.visible = false
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
	time = 0.0

func _process(delta: float) -> void:
	time += delta

func _on_boat_crashed():
	var death_ui_timer = get_tree().create_timer(2.0)
	await death_ui_timer.timeout
	stats.visible = false
	death_panel.visible = true

func _on_boat_speed_changed(value: float):
	speed_label.text = "Speed: %d" % value

func _on_boat_heading_changed(value: float):
	heading_label.text = "Heading: %d" % value
	
func _on_victory_area_entered(body):
	if body is RigidBody3D:
		victory_label.text = "Success!\nYou made it to shore in %d seconds." % int(time)
		victory_panel.visible = true
		var victory_quit_timer = get_tree().create_timer(3.0)
		await victory_quit_timer.timeout
		get_tree().quit()


func _on_play_again_button_pressed() -> void:
	get_tree().reload_current_scene()
