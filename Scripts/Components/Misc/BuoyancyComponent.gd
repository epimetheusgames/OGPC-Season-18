## Adds bouyancy functionality to objects. It's not super soffisticated (eg based 
## the hitbox and all that stuff, but it should work for now).
# Owned by carsonetb.
class_name BuoyancyComponent
extends BaseComponent


@export var center_of_mass: Node2D
@export var waves: Node2D

# Acceleration in pixels per frame (locked framerate)
@export var gravity := 16
@export var buoyancy_accel := 5.0
@export var max_buoyancy_vel := 100.0

var polygon: Polygon2D
var bouyancy_velocity := Vector2.ZERO
var is_in_air := false

func _ready() -> void:
	_ready_buoyancy()

func _ready_buoyancy() -> void:
	_ready_base_component()
	
	if waves:
		polygon = waves.get_node("Line2D")
	else:
		print("ERROR: Buoyancy component at path " + str(get_path()) + " has no waves.")

func _physics_process(delta: float) -> void:
	if !waves:
		return
	
	if !polygon:
		polygon = waves.get_node("Line2D")
	
	var current_water_height := polygon.polygon[int(polygon.polygon.size() / 2)].y + polygon.global_position.y
	
	if center_of_mass.global_position.y < current_water_height:
		is_in_air = true
		bouyancy_velocity.y += gravity * delta * 60
	elif abs(bouyancy_velocity.y) < max_buoyancy_vel:
		is_in_air = false
		bouyancy_velocity = bouyancy_velocity * 0.97
		bouyancy_velocity.y -= buoyancy_accel * delta * 60
	else:
		is_in_air = false
		bouyancy_velocity = bouyancy_velocity * 0.97
	
	if !center_of_mass is RigidBody2D:
		center_of_mass.position += bouyancy_velocity * delta
	else: # Special physics for rigidbodies.
		center_of_mass.apply_central_force(bouyancy_velocity / 4)
