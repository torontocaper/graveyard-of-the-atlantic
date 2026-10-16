class_name FloatableBody
extends RigidBody3D
## Abstract base class for objects that float (boats, buoys, etc.)

#region Properties
@export var angular_drag_factor : float = 100.0
@export var linear_drag_factor : float = 10.0
@export var float_strength : float = 200.0

var global_depth : float = 0.0
var water_area : WaterArea:
	set(value):
		if value:
			water_area = value
		else:
			water_area = null

var float_box : AABB
var float_box_corners : Array

@onready var floatable_mesh: MeshInstance3D = %FloatableMesh
#endregion

#region Methods
func _ready() -> void:
	float_box = floatable_mesh.get_aabb()
	float_box_corners.resize(8)
	for i in float_box_corners.size():
		float_box_corners.set(i, float_box.get_endpoint(i))

func _physics_process(delta: float) -> void:
	if float_box and water_area:
		global_depth = update_depth(global_position)
		linear_damp = global_depth * linear_drag_factor
		angular_damp = global_depth * angular_drag_factor
		for corner in float_box_corners:
			var corner_depth : float = update_depth(to_global(corner))
			apply_force(delta * float_strength * corner_depth * transform.basis.y, corner)

func update_depth(pos : Vector3) -> float:
	var water_height : float = water_area.get_water_height_at_position(pos.x, pos.z)
	var depth = water_height - pos.y
	if depth > 0.0:
		return depth
	else:
		return 0.0

func update_float_direction(box : AABB) -> Vector3:
	var direction = Vector3.UP
	#return direction
	for i in 8:
		var corner : Vector3 = box.get_endpoint(i)
		var depth_of_corner : float = update_depth(global_position + corner)
		var corner_dict = {
			"corner" : corner,
			"depth" : depth_of_corner
			}
		float_box_corners.set(i, corner_dict)
	float_box_corners.sort_custom(sort_by_depth)
	var deepest_corner : Dictionary = float_box_corners[0]
	var second_deepest_corner : Dictionary = float_box_corners[1]
	var third_deepest_corner : Dictionary = float_box_corners[2]
	if third_deepest_corner["depth"] > 0.0:
		var diagonal_a : Vector3 = second_deepest_corner["corner"] - deepest_corner["corner"]
		var diagonal_b : Vector3 = third_deepest_corner["corner"] - deepest_corner["corner"]
		var cross : Vector3 = diagonal_a.cross(diagonal_b)
		if cross.y < 0.0:
			print_debug("deepest corners: \n%s\n%s\n%s" % [
				str(float_box_corners[0]),
				str(float_box_corners[1]),
				str(float_box_corners[2])
				]
				)
			print_debug("diagonals: \na: %s\nb: %s" % [
				str(diagonal_a),
				str(diagonal_b)
			])
			print_debug("cross: %s" % str(cross))
		var normalized : Vector3 = cross.normalized()
		#var global : Vector3 = to_global(normalized)
		direction = normalized
	return direction

func sort_by_depth(a : Dictionary, b : Dictionary) -> bool:
	return a["depth"] > b["depth"]

#endregion
