class_name Water
extends MeshInstance3D

@export var displacement_scale : float = 0.1

var water_shader : ShaderMaterial

@onready var wave_manager: WaveManager = $"../WaveManager"

func _ready() -> void:
	water_shader = get_active_material(0)
	water_shader.set_shader_parameter("y", displacement_scale)
	

func _process(delta: float) -> void:
	water_shader.set_shader_parameter("x", randf())
