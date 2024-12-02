## Diver movement system.
class_name DiverMovement
extends Node2D

const CONST_ACCEL: int = 5
const TAP_ACCEL: int = 300
const MAX_SPEED: int = 700

var current_angle: float = 0
var input_vector: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO

@onready var diver_root: Diver = get_parent()

func _physics_process(delta: float) -> void:
	print(get_global_mouse_position())
	if !Global.is_multiplayer || get_parent()._is_node_owner():
		input_vector = get_wasd_input_vector()
		
		update_current_angle(delta * 60)
		update_movement_velocity(delta * 60)
		handle_floating(input_vector, delta)

func handle_floating(input_vector: Vector2, delta: float) -> void:
	if !diver_root.water_manager || !diver_root.water_polygon || !diver_root.water_surface_height:
		print("WARNING: Diver doesn't have water information set ... floating won't work.")
		return
	
	if global_position.y > diver_root.water_surface_height || input_vector.y > 0:
		return
		
	var water_start_pos: Vector2 = diver_root.water_polygon.polygon[0]
	var x_index := int((global_position.x - water_start_pos.x) / diver_root.water_manager.spacing)
	var current_water_height := diver_root.water_polygon.polygon[x_index].y
	diver_root.position.y = Util.better_lerp(diver_root.position.y, diver_root.water_polygon.global_position.y + current_water_height, 0.5, delta)

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
