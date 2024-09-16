class_name PlatformerMovementComponent
extends BaseComponent


@export var jump_vel := 20
@export var max_speed := 5
@export var air_max_speed := 5
@export_range(0, 1) var acceleration_percentage := 0.1
@export_range(0, 1) var air_acceleration_percentage := 0.05
@export_range(0, 1) var friction_strength := 0.7
@export_range(0, 1) var air_friction_strength := 0.5


func _ready() -> void:
	component_name = "PlatformerMovementComponent"

func _process(delta: float) -> void:
	# Make sure the container has the neccesary functions to do the job.
	if !component_container is Entity:
		print("WARNING: Component PlatformerMovementComponent at path " + str(get_path()) + " must have a parent of type Entity")
		return
	
	# Set values according to if we're on the floor to avoid having too many nested if statements.
	var acceleration_value = max_speed * acceleration_percentage
	var speed_cap = max_speed
	if !component_container.is_on_floor():
		acceleration_value = air_max_speed * air_acceleration_percentage
		speed_cap = air_max_speed
	
	# Accelerate
	if Input.is_action_pressed("left"):
		component_container.velocity -= acceleration_value * delta * 60
	if Input.is_action_pressed("right"):
		component_container.velocity += acceleration_value * delta * 60
	
	# Jump
	if Input.is_action_pressed("up") && component_container.is_on_floor(): ## TODO: Implement coyote jumping
		component_container.velocity = -jump_vel
	
	# Friction
	if !(Input.is_action_pressed("left") || Input.is_action_pressed("right")):
		component_container.velocity *= (friction_strength if component_container.velocity > 0 else -friction_strength) * delta * 60
	
	# Cap speed
	component_container.velocity = clamp(component_container.velocity, Vector2(-max_speed, -max_speed), Vector2(max_speed, max_speed))
