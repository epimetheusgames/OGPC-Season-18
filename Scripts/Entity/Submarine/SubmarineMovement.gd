# Copied by Xavier from Kai and changed a bit lool i should change this later

## Submarine movement system
class_name SubmarineMovement
extends Node2D

const CONST_ACCEL: int = 50
const TAP_ACCEL: int = 100
const MAX_SPEED: int = 500

@onready var diver = $"../../Diver"

var current_angle: float = 0.0
var input_vector: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if !Global.is_multiplayer || get_parent()._is_node_owner():
		if diver.get_state() == "DRIVING_SUBMARINE":
			input_vector = get_wasd_input_vector()
			update_current_angle(delta * 60)
			update_movement_velocity(delta * 60)
			

func get_wasd_input_vector() -> Vector2:
	var input_vector: Vector2 = Vector2.ZERO
	
	if Input.is_action_pressed("right"):
		input_vector += Vector2.RIGHT
	if Input.is_action_pressed("left"):
		input_vector += Vector2.LEFT
	if Input.is_action_pressed("up"):
		input_vector += Vector2.UP
	if Input.is_action_pressed("down"):
		input_vector += Vector2.DOWN
	
	return input_vector.normalized()

func update_current_angle(delta: float) -> void:
	if input_vector != Vector2.ZERO:
		var input_angle = input_vector.angle()
		current_angle = lerp_angle(current_angle, input_angle, 0.1 * delta)

func update_movement_velocity(delta: float):
	velocity = velocity * 0.97
	
	if input_vector != Vector2.ZERO: 
		velocity += Util.angle_to_vector(current_angle, CONST_ACCEL * delta)
	
	if Input.is_action_just_pressed("move"):
		velocity += Util.angle_to_vector(current_angle, TAP_ACCEL * delta)
	
	# Clamp velocity to MAX_SPEED
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED

func get_velocity() -> Vector2:
	return self.velocity

func get_current_angle() -> float:
	return self.current_angle
