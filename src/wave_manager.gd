@tool
extends Node
class_name WaveManager

# Each wave = (dir_x, dir_z, amplitude, speed)
@export var waves: Array[Vector4] = [
	Vector4(1.0, 0.0, 0.7, 1.0),
	Vector4(0.0, 1.0, 0.5, 0.8),
	Vector4(0.7, 0.7, 0.4, 1.3),
]

@export var wavelength: float = 12.0
var time: float = 0.0

func _process(delta: float) -> void:
	time += delta

func get_wave_height(x: float, z: float) -> float:
	var k = TAU / wavelength
	var h := 0.0
	for wave in waves:
		if wave.z == 0.0:
			continue
		var dir = Vector2(wave.x, wave.y).normalized()
		var amp = wave.z
		var spd = wave.w
		h += amp * sin(dir.dot(Vector2(x, z)) * k + spd * time)
	return h
