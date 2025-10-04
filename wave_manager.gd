@tool
extends Node
class_name WaveManager

@export var amplitude: float = 2.0
@export var wavelength: float = 12.0
@export var speed: float = 1.5
var time: float = 0.0

func _process(delta: float) -> void:
	time += delta

# Core wave height function
func get_wave_height(x: float, z: float) -> float:
	var k = 2.0 * PI / wavelength
	# var w = sqrt(9.8 * k)  # Optional: more realistic
	var wave1 = amplitude * sin(k * x + speed * time)
	var wave2 = amplitude * 0.5 * sin(k * z * 0.7 + speed * 0.8 * time)
	return wave1 + wave2

# Utility: sample multiple points at once
func get_wave_heights(points: Array[Vector3]) -> Array[float]:
	var results: Array[float] = []
	for p in points:
		results.append(get_wave_height(p.x, p.z))
	return results
