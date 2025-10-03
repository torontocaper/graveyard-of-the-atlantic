@tool
extends MeshInstance3D

@onready var mat := material_override as ShaderMaterial

@export var grid_size: int = 100         # world size of the plane
@export var grid_resolution: int = 50    # number of quads per side

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
			# Four corners of a quad
			var v00 = Vector3(-half + x * step, 0.0, -half + z * step)
			var v10 = Vector3(-half + (x + 1) * step, 0.0, -half + z * step)
			var v01 = Vector3(-half + x * step, 0.0, -half + (z + 1) * step)
			var v11 = Vector3(-half + (x + 1) * step, 0.0, -half + (z + 1) * step)

			# First triangle (v00, v10, v11)
			var n1 = (v10 - v00).cross(v11 - v00).normalized()
			verts.append_array([v00, v10, v11])
			normals.append_array([n1, n1, n1])   # all three share the same normal
			uvs.append_array([Vector2(x, z), Vector2(x+1, z), Vector2(x+1, z+1)])
			indices.append_array([index, index+1, index+2])
			index += 3

			# Second triangle (v00, v11, v01)
			var n2 = (v11 - v00).cross(v01 - v00).normalized()
			verts.append_array([v00, v11, v01])
			normals.append_array([n2, n2, n2])
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
	mat.set_shader_parameter("amplitude", WaveManager.amplitude)
	mat.set_shader_parameter("wavelength", WaveManager.wavelength)
	mat.set_shader_parameter("speed", WaveManager.speed)
	mat.set_shader_parameter("time", WaveManager.time)
