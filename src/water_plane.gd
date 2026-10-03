class_name WaterPlane
extends MeshInstance3D
## Procedurally generated water mesh

#region Constants
const TOON_WATER = preload("uid://cg56rup1h1eot")
#endregion

#region Exports
@export var water_size : Vector2 = Vector2(200, 200) ## Size of the water plane in metres
@export var water_resolution : Vector2i = Vector2i(100, 100) ## Number of subdivisions in the water plane
@export var water_jitter : float = 0.1
@export var water_base_color : Color = Color.MIDNIGHT_BLUE ## Base color of the water plane
#endregion

#region Methods
func _ready() -> void:
	# Create a new [PlaneMesh] primitive and assign it the values provided by the export vars
	mesh = create_water_plane(water_size, water_resolution, water_jitter)
	
## Create the water plane
func create_water_plane(size : Vector2, resolution : Vector2i, _jitter : float) -> ArrayMesh:
	# Create the PlaneMesh primitive and assign it the size and resolution values
	var new_plane_mesh := PlaneMesh.new()
	new_plane_mesh.size = size
	new_plane_mesh.subdivide_depth = resolution.x
	new_plane_mesh.subdivide_width = resolution.y
	
	# Get the data that describes the [PlaneMesh] and assign it to a new [ArrayMesh]
	var plane_mesh_arrays := new_plane_mesh.get_mesh_arrays()
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_mesh_arrays)
	
	# Initialize the MDT with the data from the new ArrayMesh
	var mdt : MeshDataTool = MeshDataTool.new()
	mdt.create_from_surface(array_mesh, 0)
	
	# Initialize the SurfaceTool
	var st : SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	#for f in mdt.get_face_count():
		## Get the indices for the three vertices in each face
		#var face_vertex_indices = [
			#mdt.get_face_vertex(f, 0),
			#mdt.get_face_vertex(f, 1),
			#mdt.get_face_vertex(f, 2)
			#]
		# Iterate through the vertices
		#for v in face_vertex_indices:
			#var vertex = mdt.get_vertex(v)
			#var new_vertex = vertex + Vector3(rand_f_x, 0.0, rand_f_z)
			#var new_color = water_base_color + Color(rand_f_x, rand_f_x, rand_f_x)
			##mdt.set_vertex(v, new_vertex)
			#mdt.set_vertex_color(v, Color(randf(), randf(), randf()))
	
	#array_mesh.clear_surfaces()
	#mdt.commit_to_surface(array_mesh)
	#
	## Now the mesh has new vertices and corresponding vertex colors; need to get new face normals
	#mdt.create_from_surface(array_mesh, 0)
	
	# Initialize the iterator for setting the smoothing groups
	var i = 0
	
	# Iterate through the faces in the plane
	for f in mdt.get_face_count():
		#var rand_f_x = randf_range(-displacement_range, displacement_range)
		#var rand_f_y = randf_range(-displacement_range, displacement_range)
		#var rand_f_z = randf_range(-displacement_range, displacement_range)
		#var new_color = water_base_color + Color(rand_f_y, rand_f_y, rand_f_y)
		var face_normal := mdt.get_face_normal(f)
		#print_debug("Normal for face %s is %s" % [f, face_normal])
		var face_vertices = [
			mdt.get_face_vertex(f, 0),
			mdt.get_face_vertex(f, 1),
			mdt.get_face_vertex(f, 2)
			]
		var face_color = Color(randf(), randf(), randf())
		for v in face_vertices:
			var vertex = mdt.get_vertex(v)
			st.set_color(face_color)
			st.set_normal(face_normal)
			st.set_smooth_group(i)
			st.add_vertex(vertex)
			i += 1
		i += 1
	
	# Clear out the previous array mesh data and assign the new date from the SurfaceTool
	array_mesh.clear_surfaces()
	st.commit(array_mesh)
	
	#st.deindex()
	#mdt.commit_to_surface(array_mesh)
	#for v in mdt.get_vertex_count():
		#var vertex = mdt.get_vertex(v)
		#mdt.set_vertex_color(v, water_base_color + Color(randf, randf, randf))
	#array_mesh.surface_set_material(0, TOON_WATER)
	return array_mesh

#endregion
