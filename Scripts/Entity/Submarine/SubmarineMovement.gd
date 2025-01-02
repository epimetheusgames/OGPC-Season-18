# Coded by Xavier

## Submarine movement system
class_name SubmarineMovement
extends Node2D

const CONST_ACCEL: int = 40
const TAP_ACCEL: int = 50
const MAX_SPEED: int = 7000
const MAX_ROTATION: float = 40.0
const ROTATION_RATE: float = 1.2
const BUOYANCY_CHANGE_RATE = 1
const MAX_BUOYANCY = 70.0
const MIN_BUOYANCY = -70.0

@onready var diver = Global.player
@onready var buoyancy_component = get_parent().get_node("BuoyancyComponent")

var current_angle: float = 0.0
var target_angle: float = 0.0
var input_direction: int = 0
var velocity: Vector2 = Vector2.ZERO
var buoyancy = 0

func _physics_process(delta: float) -> void:
	decay_velocity(delta)
	
	if !Global.is_multiplayer || get_parent()._is_node_owner():
		if diver.get_state() == Util.DiverState.DRIVING_SUBMARINE:
			update_movement_velocity(delta * 60)
			update_target_angle(delta)
			update_current_angle(delta * 60)
			get_parent().rotation = current_angle
			input_direction = get_input_direction()
			update_buoyancy(delta)

func decay_velocity(delta : float):
	velocity = velocity * 0.95 * delta * 60

func get_input_direction() -> int:
	input_direction = 0
	
	if Input.is_action_pressed("right"):
		input_direction += 1
	if Input.is_action_pressed("left"):
		input_direction -= 1
		
	return input_direction

func update_target_angle(delta: float) -> void:
	if Input.is_action_just_pressed("mwUP"):
		target_angle += ROTATION_RATE * delta
	if Input.is_action_just_pressed("mwDOWN"):
		target_angle -= ROTATION_RATE * delta
	target_angle = deg_to_rad(clampf(rad_to_deg(target_angle), -MAX_ROTATION, MAX_ROTATION))

func update_buoyancy(delta):
	if Input.is_action_pressed("up"):
		buoyancy += BUOYANCY_CHANGE_RATE * delta * 60
	elif Input.is_action_pressed("down"):
		buoyancy -= BUOYANCY_CHANGE_RATE * delta * 60
	buoyancy = clampf(buoyancy, MIN_BUOYANCY, MAX_BUOYANCY)
	buoyancy_component.buoyancy_accel = buoyancy

func update_current_angle(delta: float) -> void:
	current_angle = Util.better_angle_lerp(current_angle, target_angle, 0.005, delta)

func update_movement_velocity(delta: float):
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
