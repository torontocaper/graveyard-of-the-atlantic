class_name FloatableBody
extends RigidBody3D
## Object that floats (boat, buoy, etc.)

#region Properties
	#region Constants
const DRAG_COEFFICIENT : float = 1.05 ## Cube
const GRAVITY_ACCELERATION : float = 9.81 ## Acceleration due to gravity (m/s^2)
const GRAVITY_DIRECTION : Vector3 = Vector3.DOWN
const AIR_DENSITY : float = 1.225 ## Kilograms per cubic metre
const WATER_DENSITY : float = 1025.0 ## Kilograms per cubic metre #TODO: add this to the water area
	#endregion

enum MediumState {
	AIR,
	WATER
}

enum VelocityState {
	DESCENDING,
	ASCENDING,
	EQUILIBRIUM
}


## Assigned when the body enters the [WaterArea]
var water_area : WaterArea:
	set(value):
		if value:
			water_area = value
		else:
			water_area = null

	#region Force Vectors
var drag_force : Vector3
var gravity_force : Vector3
var buoyancy_direction : Vector3 = Vector3.UP
var buoyancy_force : Vector3
	#endregion

	#region Float Box
var float_box : AABB
var float_box_area : float ## Square metres
var float_box_height : float ## Metres
var float_box_volume : float ## Cubic metres
	#endregion

	#region Changing properties
var medium_state : MediumState:
	set(value):
		if medium_state != value:
			medium_state = value
			match medium_state:
				MediumState.AIR:
					print_debug("Airtime!")
					relevant_density = AIR_DENSITY
				MediumState.WATER:
					print_debug("Waterlogged!")
					relevant_density = WATER_DENSITY

var velocity_state : VelocityState:
	set(value):
		if velocity_state != value:
			velocity_state = value
			match velocity_state:
				VelocityState.DESCENDING:
					print_debug("Going down!")
				VelocityState.ASCENDING:
					print_debug("Going up!")
				VelocityState.EQUILIBRIUM:
					print_debug("Stopped")
var current_depth : float = 0.0 ## Metres
var is_submerged : bool = false:
	set(value):
		if is_submerged != value:
			is_submerged = value
			match is_submerged:
				true:
					print_debug("Fully submerged")
				false:
					print_debug("I can breathe!")
var relevant_density : float = AIR_DENSITY
var volume_displaced : float ## Cubic metres
var label_text : String
	#endregion

	#region Onready
@onready var data_label: Label3D = %DataLabel
@onready var floatable_mesh: MeshInstance3D = %FloatableMesh
	#endregion
#endregion

#region Methods
func _ready() -> void:
	gravity_force = mass * GRAVITY_ACCELERATION * GRAVITY_DIRECTION
	float_box = floatable_mesh.get_aabb()
	float_box_height = float_box.size.y
	float_box_area = float_box.size.x * float_box.size.z
	float_box_volume = float_box.get_volume()

func _process(_delta: float) -> void:
	update_label_text()

func _physics_process(delta: float) -> void:
	match signf(linear_velocity.y):
		1.0:
			velocity_state = VelocityState.ASCENDING
		-1.0:
			velocity_state = VelocityState.DESCENDING
		0.0:
			velocity_state = VelocityState.EQUILIBRIUM
	current_depth = update_depth(global_position)
	volume_displaced = update_volume_displaced(current_depth, float_box_height, float_box_volume)
	if volume_displaced == float_box_volume:
		is_submerged = true
		medium_state = MediumState.WATER
	else:
		is_submerged = false
		if velocity_state == VelocityState.ASCENDING:
			medium_state = MediumState.AIR
		else:
			medium_state = MediumState.WATER
	drag_force = update_drag_force(relevant_density, linear_velocity, DRAG_COEFFICIENT, float_box_area)
	buoyancy_force = update_buoyancy_force(WATER_DENSITY, volume_displaced, GRAVITY_ACCELERATION)
	apply_forces([gravity_force, drag_force, buoyancy_force])
	#gravity_acceleration = PhysicsServer3D.body_get_direct_state(get_rid()).total_gravity * mass
	#if float_box and water_area:
		#buoyancy_force = update_buoyancy_force()
		#apply_central_force(buoyancy_force)
		#current_depth = update_depth(global_position)
		#volume_displaced = clampf(float_box_volume * current_depth, 0.0, float_box_volume)
		##linear_damp = linear_drag_factor * current_depth
		##angular_damp = current_depth * angular_drag_factor
		#buoyancy_force = -GRAVITY_ACCELERATION * WATER_DENSITY * volume_displaced
		##apply_central_force(gravity_force)
		##for corner in float_box_corners:
			##var corner_depth : float = update_depth(to_global(corner))
			###ALERT: don't delete apply_force(delta * float_strength * corner_depth * global_transform.basis.y, corner)
			#match Vector2(corner.x, corner.z).sign():
				#Vector2(-1.0, -1.0):
					#float_indicator_nw.text = str(snappedf(corner_depth, 0.01))
				#Vector2(-1.0, 1.0):
					#float_indicator_sw.text = str(snappedf(corner_depth, 0.01))
				#Vector2(1.0, -1.0):
					#float_indicator_ne.text = str(snappedf(corner_depth, 0.01))
				#Vector2(1.0, 1.0):
					#float_indicator_se.text = str(snappedf(corner_depth, 0.01))

func update_depth(pos : Vector3) -> float:
	if water_area == null:
		return 0.0
	else: 
		var water_height : float = water_area.get_water_height_at_position(pos.x, pos.z)
		var depth = water_height - pos.y
		if depth > 0.0:
			return depth
		else:
			return 0.0

func update_volume_displaced(depth_of_object : float, height_of_object : float, volume_of_object : float) -> float:
	var displaced_portion : float = clampf(depth_of_object / height_of_object, 0.0, 1.0)
	var displaced_volume : float = displaced_portion * volume_of_object
	return displaced_volume

#region Forces
func apply_forces(forces : Array[Vector3]) -> void:
	for force in forces:
		apply_central_force(force)

## Calculate the buoyancy force
## rho is density of fluid; V is displaced volume; g is acceleration of gravity
func update_buoyancy_force(rho : float, V : float, g : float) -> Vector3:
	return (rho * V * g) * buoyancy_direction

## Calculate the drag force
## rho is density of fluid; v is velocity; C_d is drag coefficient; A is orthogonal area
func update_drag_force(rho : float, v : Vector3, C_d : float, A : float) -> Vector3:
	var velocity_magnitude : float = v.length()
	var velocity_direction : Vector3 = v.normalized()
	return ((0.5) * rho * (velocity_magnitude ** 2) * C_d * A) * -velocity_direction
#endregion


func update_label_text() -> void:
	label_text = "
	name: %s\n\
	angular v: %s\n\
	linear v: %s\n\
	global depth: %s\n\
	volume displaced: %s\n\
	buoyancy force: %s\n\
	drag force: %s\n\
	gravity force: %s
	" % [
		name,
		angular_velocity.snappedf(0.1),
		linear_velocity.snappedf(0.1),
		snappedf(current_depth, 0.1),
		snappedf(volume_displaced, 0.01),
		buoyancy_force.snappedf(100.0),
		drag_force.snappedf(1.0),
		gravity_force.snappedf(0.01)
	]
	data_label.text = label_text

#func update_float_direction(box : AABB) -> Vector3:
	#var direction = Vector3.UP
	##return direction
	#for i in 8:
		#var corner : Vector3 = box.get_endpoint(i)
		#var depth_of_corner : float = update_depth(global_position + corner)
		#var corner_dict = {
			#"corner" : corner,
			#"depth" : depth_of_corner
			#}
		#float_box_corners.set(i, corner_dict)
	#float_box_corners.sort_custom(sort_by_depth)
	#var deepest_corner : Dictionary = float_box_corners[0]
	#var second_deepest_corner : Dictionary = float_box_corners[1]
	#var third_deepest_corner : Dictionary = float_box_corners[2]
	#if third_deepest_corner["depth"] > 0.0:
		#var diagonal_a : Vector3 = second_deepest_corner["corner"] - deepest_corner["corner"]
		#var diagonal_b : Vector3 = third_deepest_corner["corner"] - deepest_corner["corner"]
		#var cross : Vector3 = diagonal_a.cross(diagonal_b)
		#if cross.y < 0.0:
			#print_debug("deepest corners: \n%s\n%s\n%s" % [
				#str(float_box_corners[0]),
				#str(float_box_corners[1]),
				#str(float_box_corners[2])
				#]
				#)
			#print_debug("diagonals: \na: %s\nb: %s" % [
				#str(diagonal_a),
				#str(diagonal_b)
			#])
			#print_debug("cross: %s" % str(cross))
		#var normalized : Vector3 = cross.normalized()
		##var global : Vector3 = to_global(normalized)
		#direction = normalized
	#return direction

func sort_by_depth(a : Dictionary, b : Dictionary) -> bool:
	return a["depth"] > b["depth"]

#endregion
