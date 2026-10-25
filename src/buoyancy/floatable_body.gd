class_name FloatableBody
extends RigidBody3D
## Object that floats (boat, buoy, etc.)

#region Properties
	#region Constants
const DRAG_COEFFICIENT : float = 1.05 ## Cube
const GRAVITY_ACCELERATION : float = 9.81 ## Acceleration due to gravity (m/s^2)
const AIR_DENSITY : float = 1.225 ## Kilograms per cubic metre
const WATER_DENSITY : float = 1025.0 ## Kilograms per cubic metre #TODO: add this to the water area
	#endregion

	#region Enums
enum Density {
	AIR,
	WATER
}

enum MediumState {
	SUBMERGED,
	AIRBORNE,
	LIMINAL
}

enum VelocityState {
	DESCENDING,
	ASCENDING,
	EQUILIBRIUM
}
	#endregion

## Assigned when the body enters the [WaterArea]
var water_area : WaterArea:
	set(value):
		if value:
			water_area = value
		else:
			water_area = null

	#region Force Vectors
var gravity_direction : Vector3 = Vector3.DOWN
var buoyancy_direction : Vector3 = Vector3.UP
var drag_force : Vector3
var gravity_force : Vector3
var buoyancy_force : Vector3
var net_force : Vector3
	#endregion

	#region Float Box
var float_box : AABB
var float_box_area : float ## Square metres
var float_box_height : float ## Metres
var float_box_volume : float ## Cubic metres
	#endregion

	#region States
var medium_state : MediumState
var velocity_state : VelocityState
	#endregion

	#region Other changing properties
var altitude : float = 0.0
var depth : float = 0.0
var water_height : float
var relevant_density : Density
var volume_displaced : float ## Cubic metres
	#endregion

	#region Onready
@onready var data_label: Label3D = %DataLabel
@onready var floatable_mesh: MeshInstance3D = %FloatableMesh
	#endregion
#endregion

#region Methods
func _ready() -> void:
	gravity_force = mass * GRAVITY_ACCELERATION * gravity_direction
	float_box = floatable_mesh.get_aabb()
	float_box_height = float_box.size.y
	float_box_area = float_box.size.x * float_box.size.z
	float_box_volume = float_box.get_volume()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.linear_velocity += net_force * state.step / mass

func _process(_delta: float) -> void:
	altitude = global_position.y
	water_height = update_water_height()
	if altitude <= water_height:
		depth = update_depth(global_position, water_height)
	else:
		depth = 0.0
	volume_displaced = update_volume_displaced(depth, float_box_height, float_box_volume)
	medium_state = update_medium_state(volume_displaced, float_box_volume)
	data_label.text = update_label_text()

func _physics_process(_delta: float) -> void:
	velocity_state = update_velocity_state(linear_velocity.y)
	relevant_density = update_relevant_density(velocity_state, medium_state)
	var drag_rho : float = AIR_DENSITY if relevant_density == Density.AIR else WATER_DENSITY
	drag_force = update_drag_force(drag_rho, linear_velocity, DRAG_COEFFICIENT, float_box_area)
	buoyancy_force = update_buoyancy_force(WATER_DENSITY, volume_displaced, GRAVITY_ACCELERATION)
	net_force = drag_force + buoyancy_force + gravity_force

func update_depth(position_of_object : Vector3, height_of_water : float) -> float:
	return height_of_water - position_of_object.y

func update_relevant_density(v_state : VelocityState, m_state: MediumState) -> Density:
	if m_state == MediumState.SUBMERGED:
		return Density.WATER
	elif m_state == MediumState.AIRBORNE:
		return Density.AIR
	else:
		if v_state == VelocityState.ASCENDING:
			return Density.AIR
		else:
			return Density.WATER

func update_medium_state(displaced : float, total : float) -> MediumState:
	if displaced == 0:
		return MediumState.AIRBORNE
	elif displaced == total:
		return MediumState.SUBMERGED
	else:
		return MediumState.LIMINAL

func update_velocity_state(velocity : float) -> VelocityState:
	match signf(velocity):
		1.0:
			return VelocityState.ASCENDING
		-1.0:
			return VelocityState.DESCENDING
		0.0:
			return VelocityState.EQUILIBRIUM
		_:
			print_debug("ERROR: unknown velocity")
			return velocity_state

func update_volume_displaced(depth_of_object : float, height_of_object : float, volume_of_object : float) -> float:
	var displaced_portion : float = clampf(depth_of_object / height_of_object, 0.0, 1.0)
	var displaced_volume : float = displaced_portion * volume_of_object
	return displaced_volume

func update_water_height() -> float:
	if water_area:
		return water_area.get_water_height_at_position(global_position.x, global_position.z)
	else:
		return 0.0

#region Force updates
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

func update_label_text() -> String:
	var text : String = "
	name: %s\n\
	angular v: %s\n\
	linear v: %s\n\
	altitude: %s\n\
	depth: %s\n\
	water height: %s\n\
	volume displaced: %s\n\
	relevant density: %s\n\
	medium state: %s\n\
	velocity state: %s\n\
	buoyancy force: %s\n\
	drag force: %s\n\
	gravity force: %s
	net force: %s
	" % [
		name,
		angular_velocity.snappedf(0.1),
		linear_velocity.snappedf(0.1),
		snappedf(altitude, 0.1),
		snappedf(depth, 0.1),
		snapped(water_height, 0.1),
		snappedf(volume_displaced, 0.01),
		Density.keys()[relevant_density],
		MediumState.keys()[medium_state],
		VelocityState.keys()[velocity_state],
		buoyancy_force.snappedf(100.0),
		drag_force.snappedf(1.0),
		gravity_force.snappedf(0.01),
		net_force.snappedf(0.01),
	]
	return text
#endregion
