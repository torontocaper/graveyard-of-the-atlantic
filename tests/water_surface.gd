class_name WaterMesh
extends MeshInstance3D

var array_mesh : ArrayMesh
var mdt : MeshDataTool

func _ready() -> void:
	var mesh_arrays : Array = mesh.surface_get_arrays(0)
	mesh_arrays.resize(Mesh.ARRAY_MAX)
	array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
	mdt = MeshDataTool.new()
	mdt.create_from_surface(array_mesh, 0)
