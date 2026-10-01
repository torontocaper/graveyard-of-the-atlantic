#@tool
extends MeshInstance3D

@export var width : float = 10.0
@export var resolution : int = 10

var i_m : ImmediateMesh
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	i_m = mesh

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	i_m.clear_surfaces()
	i_m.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for x in resolution:
		for z in resolution:
			i_m.surface_set_color(Color.AQUA)
			i_m.surface_set_normal(Vector3.UP)
			i_m.surface_add_vertex(Vector3(x, 0, z))
	i_m.surface_end()
