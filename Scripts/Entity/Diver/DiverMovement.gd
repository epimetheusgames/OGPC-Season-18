## Diver movement system.
# Owned by: kaitaobenson

class_name DiverMovement
extends Node2D

const CONST_ACCEL: int = 5
const TAP_ACCEL: int = 300
const MAX_SPEED: int = 700

var current_angle: float = 0
var input_vector: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO

@onready var diver_root: Diver = get_parent()
@export var use_mouse_movement := false

signal boosted

func _physics_process(delta: float) -> void:
	if !Global.is_multiplayer || get_parent()._is_node_owner():
		if get_parent().get_state() != Util.DiverState.DRIVING_SUBMARINE:
			input_vector = get_input_vector()
			
			update_current_angle(delta * 60)
			update_movement_velocity(delta * 60)

func get_input_vector() -> Vector2:
	if use_mouse_movement:
		return get_mouse_input_vector()
	return get_wasd_input_vector()

func get_wasd_input_vector() -> Vector2:
	input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("right"):
		input_vector += Vector2.RIGHT
	if Input.is_action_pressed("left"):
		input_vector += Vector2.LEFT
	if Input.is_action_pressed("up"):
		input_vector += Vector2.UP
	if Input.is_action_pressed("down"):
		input_vector += Vector2.DOWN
	
	return input_vector.normalized()

# This is mostly a workaround for now until the bug with getting the mouse 
# position inside a viewport gets fixed (https://github.com/godotengine/godot/issues/99912)
func get_mouse_input_vector() -> Vector2:
	return (Vector2(DisplayServer.mouse_get_position()) - Vector2(960, 540)).normalized()

func update_current_angle(delta: float) -> void:
	if input_vector != Vector2.ZERO:
		var input_angle = input_vector.angle()
		current_angle = lerp_angle(current_angle, input_angle, 0.1 * delta)

func update_movement_velocity(delta: float):
	velocity = velocity * 0.97
	
	if input_vector != Vector2.ZERO: 
		velocity += Util.angle_to_vector_radians(current_angle, CONST_ACCEL * delta)
	
	if Input.is_action_just_pressed("move"):
		velocity += Util.angle_to_vector_radians(current_angle, TAP_ACCEL * delta)
		boosted.emit()
	
	# Clamp velocity to MAX_SPEED
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED

func knockback(force: Vector2) -> void:
	velocity += force

func get_velocity() -> Vector2:
	return self.velocity

func get_current_angle() -> float:
	return self.current_angle
