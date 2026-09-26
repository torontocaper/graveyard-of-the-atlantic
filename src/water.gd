class_name Water
extends MeshInstance3D

@export var boat : Rowboat

@export_group("Waves")
@export var x_wave : Vector3 = Vector3(
	0.05,
	1.5,
	0.1
):
	set(value):
		x_wave = value
		set_shader_parameters()
@export var z_wave : Vector3 = Vector3(
	0.05,
	1.5,
	0.1
):
	set(value):
		z_wave = value
		set_shader_parameters()
@export var diagonal_wave : Vector3 = Vector3(
	0.15,
	0.1,
	0.3
):
	set(value):
		diagonal_wave = value
		set_shader_parameters()

#@export var x_wave.x : float = 0.05 ## Peak deviation from zero aka maximum height in metres
#@export var x_wave.y : float = 1.5 ## Number of waves per second?
#@export var x_wave.z : float = 0.1 ## Velocity of wave in metres/second
#
#@export var z_wave.x : float = 0.1 ## Peak deviation from zero aka maximum height in metres
#@export var z_wave.y : float = 0.6 ## Number of waves per second?
#@export var z_wave.z : float = 0.35 ## Velocity of wave in metres/second
#
#@export var diagonal_wave.x : float = 0.15 ## Peak deviation from zero aka maximum height in metres
#@export var diagonal_wave.y : float = 0.1 ## Number of waves per second?
#@export var diagonal_wave.z : float = 0.3 ## Velocity of wave in metres/second

var water_shader : ShaderMaterial
var water_body : StaticBody3D
var water_shape : ConcavePolygonShape3D

func _ready() -> void:
	create_trimesh_collision()
	water_body = get_child(0) as StaticBody3D
	water_shape = water_body.get_child(0).shape
	water_shader = get_active_material(0)
	set_shader_parameters()

func _physics_process(_delta: float) -> void:
	if water_shape:
		var old_faces : PackedVector3Array = water_shape.get_faces()
		var new_faces : PackedVector3Array = []
		for face in old_faces:
			new_faces.append(Vector3(face.x, get_height_at_position(face.x, face.z), face.z))
		water_shape.set_faces(new_faces)

func get_height_at_position(position_x : float, position_z : float) -> float:
	var height : float
	var x_wave_value : float = x_wave.x * sin( (2.0 * PI * x_wave.y) * ( position_x + Time.get_ticks_msec() * x_wave.z  ));
	var z_wave_value : float = z_wave.x * sin( (2.0 * PI * z_wave.y) * ( position_z + Time.get_ticks_msec() * z_wave.z  ));
	var diagonal_wave_value : float = diagonal_wave.x * sin( (2.0 * PI * diagonal_wave.y) * ( position_x + position_z +  Time.get_ticks_msec() * diagonal_wave.z ));
	height = x_wave_value + z_wave_value + diagonal_wave_value;
	return height

func set_shader_parameters() -> void:
	if water_shader:
		water_shader.set_shader_parameter("x_amplitude", x_wave.x)
		water_shader.set_shader_parameter("x_frequency", x_wave.y)
		water_shader.set_shader_parameter("x_speed", x_wave.z)
		water_shader.set_shader_parameter("z_amplitude", z_wave.x)
		water_shader.set_shader_parameter("z_frequency", z_wave.y)
		water_shader.set_shader_parameter("z_speed", z_wave.z)
		water_shader.set_shader_parameter("diagonal_amplitude", diagonal_wave.x)
		water_shader.set_shader_parameter("diagonal_frequency", diagonal_wave.y)
		water_shader.set_shader_parameter("diagonal_speed", diagonal_wave.z)
