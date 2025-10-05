@tool
extends MeshInstance3D
## Procedurally builds a faceted ocean mesh using SurfaceTool.
## Each triangle has its own vertices and per-face normal, guaranteeing flat shading.

@export var wave_manager: WaveManager
@export_category("Grid settings")
@export var grid_size: int = 100
@export var grid_resolution: int = 50

@onready var mat: ShaderMaterial = material_override as ShaderMaterial


func _ready() -> void:
	mesh = build_faceted_grid(grid_size, grid_resolution)

func build_faceted_grid(size: int, resolution: int) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var half := float(size) / 2.0
	var step := float(size) / float(resolution)

	for x in range(resolution):
		for z in range(resolution):
			var v00 := Vector3(-half + x * step, 0.0, -half + z * step)
			var v10 := Vector3(-half + (x + 1) * step, 0.0, -half + z * step)
			var v01 := Vector3(-half + x * step, 0.0, -half + (z + 1) * step)
			var v11 := Vector3(-half + (x + 1) * step, 0.0, -half + (z + 1) * step)

			# First triangle
			_add_triangle(st, v00, v10, v11)
			# Second triangle
			_add_triangle(st, v00, v11, v01)

	var new_mesh := st.commit()
	return new_mesh


func _add_triangle(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	## Compute a flat normal for the face
	var normal := Plane(a, b, c).normal
	var color := Color(randf(), randf(), randf())
	for v in [a, b, c]:
		st.set_normal(normal)
		st.set_color(color)
		st.add_vertex(v)


func _process(_delta: float) -> void:
	if mat and wave_manager:
		mat.set_shader_parameter("wavelength", wave_manager.wavelength)
		mat.set_shader_parameter("time", wave_manager.time)
		mat.set_shader_parameter("waves", wave_manager.waves)
