class_name Water
extends MeshInstance3D

@export var x_wave_amplitude : float = 2.0 ## Peak deviation from zero aka maximum height in metres
@export var x_wave_frequency : float = 2.0 ## Number of waves per second?
@export var x_wave_speed : float = 0.1 ## Velocity of wave in metres/second

@export var z_wave_amplitude : float = 2.0 ## Peak deviation from zero aka maximum height in metres
@export var z_wave_frequency : float = 2.0 ## Number of waves per second?
@export var z_wave_speed : float = 0.1 ## Velocity of wave in metres/second

var water_shader : ShaderMaterial

func _ready() -> void:
	water_shader = get_active_material(0)
	water_shader.set_shader_parameter("x_amplitude", x_wave_amplitude)
	water_shader.set_shader_parameter("x_frequency", x_wave_frequency)
	water_shader.set_shader_parameter("x_speed", x_wave_speed)
	water_shader.set_shader_parameter("z_amplitude", z_wave_amplitude)
	water_shader.set_shader_parameter("z_frequency", z_wave_frequency)
	water_shader.set_shader_parameter("z_speed", z_wave_speed)

func get_wave_height_at_position_1d(position_x : float) -> float:
	var height : float
	height = x_wave_amplitude * ( sin( ( 2.0 * PI * x_wave_frequency ) * ( ( position_x + Time.get_ticks_msec() ) * x_wave_speed ) ) )
	return height
