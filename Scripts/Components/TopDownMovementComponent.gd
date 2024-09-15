## TODO: Have a base MovementComponent class because there is some duplicate code in here.
class_name TopDownMovementComponent
extends BaseComponent


@export var max_speed := 5
@export_range(0, 1) var acceleration_percentage := 0.1
@export_range(0, 1) var friction_strength := 0.7

func _ready() -> void:
	component_name = "TopDownMovementComponent"

func _process(delta: float) -> void:
	# Make sure the container has the neccesary functions to do the job.
	if !component_container is CharacterBody2D:
		print("WARNING: Component PlatformerMovementComponent at path " + str(get_path()) + " must have a parent of type CharacterBody2D")
		return
	
	var final_velocity_addon = Vector2.ZERO
	
	if Input.is_action_pressed("up"):
		final_velocity_addon.y -= acceleration_percentage
	if Input.is_action_pressed("down"):
		final_velocity_addon.y += acceleration_percentage
	if Input.is_action_pressed("left"):
		final_velocity_addon.x -= acceleration_percentage
	if Input.is_action_pressed("right"):
		final_velocity_addon.x += acceleration_percentage
	
	
	# Normalize for diagonals to remain 'circular'
	final_velocity_addon = final_velocity_addon.normalized() * max_speed * delta * 60
	component_container.velocity += final_velocity_addon
	
	# Run friction
	if !Input.is_action_pressed("up") && !Input.is_action_pressed("down") && \
	   !Input.is_action_pressed("left") && !Input.is_action_pressed("right"):
		component_container.velocity *= friction_strength * delta * 60
	
	# Make sure container velocity isn't too high.
	component_container.velocity = clamp(component_container.velocity, Vector2(-max_speed, -max_speed), Vector2(max_speed, max_speed))
	
