class_name FloatableBody
extends RigidBody3D
## Abstract base class for objects that float (boats, buoys, etc.)

#region Properties
const ANGULAR_DRAG : float = 0.99
const LINEAR_DRAG : float = 0.05
const FLOAT_STRENGTH : float = 1000.0

@export var buoyancy_component : BuoyancyComponent

var float_forces : Array[Vector3] = [
	Vector3.ZERO,
	Vector3.ZERO,
	Vector3.ZERO,
	]
var float_points : Array[Vector3] = [
	Vector3.ZERO,
	Vector3.ZERO,
	Vector3.ZERO,
	]

var pontoons : Array[Pontoon]

var water_area : WaterArea:
	set(value):
		if value:
			water_area = value
			buoyancy_component.water_area = water_area
		else:
			water_area = null
#endregion

#region Methods
func _ready() -> void:
	if buoyancy_component:
		pontoons = buoyancy_component.pontoons

func _physics_process(delta: float) -> void:
	if water_area and pontoons:
		# Apply flotation
		for pontoon_index in pontoons.size():
			var this_pontoon : Pontoon = pontoons[pontoon_index]
			var this_force : Vector3 = FLOAT_STRENGTH * delta * this_pontoon.depth * buoyancy_component.buoyancy_direction
			float_forces[pontoon_index] = this_force
			var this_point : Vector3 = global_position + this_pontoon.position
			float_points[pontoon_index] = this_point
			apply_force(this_force, this_point)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	#apply_central_force(Vector3.DOWN * GRAVITY_STRENGTH)
	state.angular_velocity *= 1.0 - ANGULAR_DRAG
	state.linear_velocity *= 1.0 - LINEAR_DRAG

#endregion
