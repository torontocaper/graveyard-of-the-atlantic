@tool
extends MeshInstance3D


@export var wave_manager: WaveManager
@export_category("Grid settings")
@export var grid_size: int = 100
@export var grid_resolution: int = 50

@onready var mat := material_override as ShaderMaterial

func _ready() -> void:
	mesh = build_faceted_grid(grid_size, grid_resolution)

func build_faceted_grid(size: int, resolution: int) -> ArrayMesh:
	var arrays = []
	var verts = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	var indices = PackedInt32Array()

	var half = float(size) / 2.0
	var step = float(size) / float(resolution)

	var index = 0
	for x in range(resolution):
		for z in range(resolution):
			var v00 = Vector3(-half + x * step, 0.0, -half + z * step)
			var v10 = Vector3(-half + (x + 1) * step, 0.0, -half + z * step)
			var v01 = Vector3(-half + x * step, 0.0, -half + (z + 1) * step)
			var v11 = Vector3(-half + (x + 1) * step, 0.0, -half + (z + 1) * step)

			verts.append_array([v00, v10, v11])
			normals.append_array([Vector3.UP, Vector3.UP, Vector3.UP])
			uvs.append_array([Vector2(x, z), Vector2(x+1, z), Vector2(x+1, z+1)])
			indices.append_array([index, index+1, index+2])
			index += 3

			verts.append_array([v00, v11, v01])
			normals.append_array([Vector3.UP, Vector3.UP, Vector3.UP])
			uvs.append_array([Vector2(x, z), Vector2(x+1, z+1), Vector2(x, z+1)])
			indices.append_array([index, index+1, index+2])
			index += 3

	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return arr_mesh

func _process(_delta: float) -> void:
	if mat:
		mat.set_shader_parameter("wavelength", wave_manager.wavelength)
		mat.set_shader_parameter("time", wave_manager.time)
		mat.set_shader_parameter("waves", wave_manager.waves)
