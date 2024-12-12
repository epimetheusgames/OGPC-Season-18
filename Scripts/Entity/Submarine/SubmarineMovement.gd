# Copied by Xavier from Kai and changed a bit lool i should change this later

## Submarine movement system
class_name SubmarineMovement
extends Node2D

const CONST_ACCEL: int = 25
const TAP_ACCEL: int = 50
const MAX_SPEED: int = 500
const MAX_ROTATION: float= 90.0
const ROTATION_RATE: float = 2.0

#@onready var diver = $"../../Diver"

var current_angle: float = 0.0
var target_angle: float = 0.0
var input_direction: int = 0
var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
#	if !Global.is_multiplayer || get_parent()._is_node_owner():
#		if diver.get_state() == "DRIVING_SUBMARINE":
	update_target_angle(delta)
	update_current_angle(delta * 60)
	print(rad_to_deg(current_angle))
	get_parent().rotation = current_angle
	input_direction = get_input_direction()
	update_movement_velocity(delta * 60)

func get_input_direction() -> int:
	var input_direction = 0
	
	if Input.is_action_pressed("right"):
		input_direction += 1
	if Input.is_action_pressed("left"):
		input_direction -= 1
		
	return input_direction

func update_target_angle(delta: float) -> void:
	if Input.is_action_pressed("up"):
		target_angle += ROTATION_RATE * delta
	if Input.is_action_pressed("down"):
		target_angle -= ROTATION_RATE * delta
	target_angle = deg_to_rad(clampf(rad_to_deg(target_angle), -MAX_ROTATION, MAX_ROTATION))

func update_current_angle(delta: float) -> void:
	current_angle = lerp_angle(current_angle, target_angle, 0.05 * delta)

func update_movement_velocity(delta: float):
	velocity = velocity * 0.97
	
	velocity += input_direction * Util.angle_to_vector(current_angle, CONST_ACCEL * delta)
	
	if Input.is_action_just_pressed("move"):
		velocity += input_direction * Util.angle_to_vector(current_angle, TAP_ACCEL * delta)
	
	# Clamp velocity to MAX_SPEED
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED

func get_velocity() -> Vector2:
	return self.velocity

func get_current_angle() -> float:
	return self.current_angle
