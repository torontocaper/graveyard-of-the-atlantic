@tool
class_name Landmass
extends MeshInstance3D

@export var force_update : bool = false

@export_group("Landmass Properties", "landmass_")
@export var landmass_size : Vector2 = Vector2(200.0, 200.0)
@export var landmass_resolution : Vector2i = Vector2i(400, 400)
@export var landmass_max_height : float = 100.0
#@export var landmass_noise : Noise

@onready var landmass_collider: CollisionShape3D = %LandmassCollider

func _ready() -> void:
	create_landmass()

func _process(delta: float) -> void:
	if force_update:
		create_landmass()
		force_update = false

func create_landmass() -> void:
	# Create the PlaneMesh primitive and assign it the size and resolution values
	var new_plane_mesh := PlaneMesh.new()
	new_plane_mesh.size = landmass_size
	new_plane_mesh.subdivide_width = landmass_resolution.x
	new_plane_mesh.subdivide_depth = landmass_resolution.y

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

	# Initialize the noise with a random seed
	var noise : Noise = FastNoiseLite.new()
	noise.seed = randi()
	
	# Apply height displacement to vertices
	for v in mdt.get_vertex_count():
		var vertex = mdt.get_vertex(v)
		vertex.y += landmass_max_height * noise.get_noise_2d(vertex.x, vertex.z)
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

	# Assign that mesh to this mesh
	mesh = array_mesh

	# Create the collision shape and assign it to the collider's shape property
	var landmass_shape := mesh.create_trimesh_shape()
	landmass_collider.shape = landmass_shape

	# Send the height range to the shader
	var landmass_shader = material_override as ShaderMaterial
	#var height_range = landmass_max_height * 2.0
	landmass_shader.set_shader_parameter("max_height", landmass_max_height)
	#landmass_shader.set_shader_parameter("height_range", height_range)
