class_name WaterPlane
extends MeshInstance3D

@export var displacement_range : float = 0.1
@export var water_size : Vector2 = Vector2(200, 200)
@export var water_resolution : Vector2i = Vector2i(100, 100)
@export var water_base_color : Color = Color.MIDNIGHT_BLUE

const TOON_WATER = preload("uid://cg56rup1h1eot")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var new_plane_mesh := PlaneMesh.new()
	new_plane_mesh.size = water_size
	new_plane_mesh.subdivide_depth = water_resolution.x
	new_plane_mesh.subdivide_width = water_resolution.y
	var plane_mesh_arrays := new_plane_mesh.get_mesh_arrays()
	for array in plane_mesh_arrays:
		print_debug(array)
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_mesh_arrays)
	var mdt : MeshDataTool = MeshDataTool.new()
	mdt.create_from_surface(array_mesh, 0)
	var st : SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for f in mdt.get_face_count():
		#var face_normal := mdt.get_face_normal(f)
		var rand_f_x = randf_range(-displacement_range, displacement_range)
		var rand_f_y = randf_range(-displacement_range, displacement_range)
		var rand_f_z = randf_range(-displacement_range, displacement_range)
		var face_vertices = [
			mdt.get_face_vertex(f, 0),
			mdt.get_face_vertex(f, 1),
			mdt.get_face_vertex(f, 2)
			]
		print_debug("Face %s uses vertices %s" % [f, face_vertices])
		for v in face_vertices:
			var vertex = mdt.get_vertex(v)
			print_debug(vertex)
			var new_vertex = vertex + Vector3(rand_f_x, rand_f_y, rand_f_z)
			var new_color = water_base_color + Color(rand_f_y, rand_f_y, rand_f_y)
			mdt.set_vertex(v, new_vertex)
			mdt.set_vertex_color(v, new_color)

	array_mesh.clear_surfaces()
	mdt.commit_to_surface(array_mesh)
	#array_mesh.regen_normal_maps()
	# Now the mesh has new vertices and corresponding vertex colors; need to get new face normals
	mdt.create_from_surface(array_mesh, 0)
	var i = 0
	for f in mdt.get_face_count():
		#var rand_f_x = randf_range(-displacement_range, displacement_range)
		var rand_f_y = randf_range(-displacement_range, displacement_range)
		#var rand_f_z = randf_range(-displacement_range, displacement_range)
		var new_color = water_base_color + Color(rand_f_y, rand_f_y, rand_f_y)
		var face_normal := mdt.get_face_normal(f)
		print_debug("Normal for face %s is %s" % [f, face_normal])
		var face_vertices = [
			mdt.get_face_vertex(f, 0),
			mdt.get_face_vertex(f, 1),
			mdt.get_face_vertex(f, 2)
			]
		for v in face_vertices:
			var vertex = mdt.get_vertex(v)
			#var v_color = mdt.get_vertex_color(v)
			st.set_color(new_color)
			st.set_normal(face_normal)
			st.set_smooth_group(i)
			st.add_vertex(vertex)
			i += 1
		i += 1
	array_mesh.clear_surfaces()
	#st.deindex()
	st.commit(array_mesh)
	
	#mdt.commit_to_surface(array_mesh)
	#for v in mdt.get_vertex_count():
		#var vertex = mdt.get_vertex(v)
		#mdt.set_vertex_color(v, water_base_color + Color(randf, randf, randf))
	#array_mesh.surface_set_material(0, TOON_WATER)
	mesh = array_mesh

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
