class_name FloatableBody
extends RigidBody3D
## Abstract base class for objects that float (boats, buoys, etc.)

#region Properties
const ANGULAR_DRAG : float = 0.99
const LINEAR_DRAG : float = 0.1
const FLOAT_STRENGTH : float = 1000.0
#const GRAVITY_STRENGTH : float = 9.8

@export var buoyancy_component : BuoyancyComponent

var water_area : WaterArea:
	set(value):
		if value:
			water_area = value
			buoyancy_component.water_area = water_area
		else:
			water_area = null
#endregion

#region Methods
#func _ready() -> void:
	#custom_integrator = true

func _physics_process(delta: float) -> void:
	if water_area:
		# Apply flotation
		for pontoon in buoyancy_component.pontoons:
			apply_force(FLOAT_STRENGTH * delta * pontoon.depth * buoyancy_component.buoyancy_direction, global_position + pontoon.position)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	#apply_central_force(Vector3.DOWN * GRAVITY_STRENGTH)

	state.angular_velocity *= 1.0 - ANGULAR_DRAG
	state.linear_velocity *= 1.0 - LINEAR_DRAG

#endregion
