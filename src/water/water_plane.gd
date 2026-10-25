@tool
class_name WaterPlane
extends MeshInstance3D
## Procedurally generated water mesh

#region Properties
var water_properties : Dictionary:
	set(value):
		water_properties = value
		update_water_plane(
			water_properties["water_size"],
			water_properties["water_resolution"],
			water_properties["water_jitter"],
			water_properties["water_base_color"]
			)
#endregion

#region Methods
## Update the water plane
func update_water_plane(size : Vector2, resolution : Vector2i, jitter : float, base_color : Color) -> void:
	# Create the PlaneMesh primitive and assign it the size and resolution values
	var new_plane_mesh := PlaneMesh.new()
	new_plane_mesh.size = size
	new_plane_mesh.subdivide_width = resolution.x
	new_plane_mesh.subdivide_depth = resolution.y
	
	# Get the data that describes the [PlaneMesh] and assign it to a new [ArrayMesh]
	var plane_mesh_arrays := new_plane_mesh.get_mesh_arrays()
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_mesh_arrays)
	
	# Initialize the MDT with the data from the new ArrayMesh
	var mdt : MeshDataTool = MeshDataTool.new()
	mdt.create_from_surface(array_mesh, 0)
	
	# Initialize the SurfaceTool (necessary for setting "smooth groups" for flat-shading)
	var st : SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Apply jitter to vertices
	for v in mdt.get_vertex_count():
		var vertex = mdt.get_vertex(v)
		vertex.x += randf_range(-jitter, jitter)
		vertex.z += randf_range(-jitter, jitter)
		mdt.set_vertex(v, vertex)

	# Create the smoothing groups
	var i : int = 0
	for f in mdt.get_face_count():
		var face_vertex_indices = [
			mdt.get_face_vertex(f, 0),
			mdt.get_face_vertex(f, 1),
			mdt.get_face_vertex(f, 2)
			]
		for v in face_vertex_indices:
			var vertex = mdt.get_vertex(v)
			st.set_smooth_group(v)
			st.add_vertex(vertex)
			i += 1
		i += 1

	# Clear out the previous array mesh data and assign the new date from the SurfaceTool
	array_mesh.clear_surfaces()
	st.commit(array_mesh)
	mesh = array_mesh

	# Update the shader
	var water_shader = material_override as ShaderMaterial
	water_shader.set_shader_parameter("water_color", base_color)
#endregion
