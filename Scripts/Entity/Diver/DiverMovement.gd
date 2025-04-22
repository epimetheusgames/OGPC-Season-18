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
var is_in_gravity_area := false
var spawned_in_research_station := false
var is_in_research_station := true
var is_in_ladder_area := false
var is_climbing_ladder := false
var ladder: Area2D = null


@onready var saveable_timer := get_tree().create_timer(0.5)

@onready var diver: Diver = get_parent()
@export var use_mouse_movement := false
@export var gravity := 1.0
@export var knockback_velocity := 200.0

signal boosted

func _physics_process(delta: float) -> void:
	if (Global.is_multiplayer && !diver._is_node_owner()) || diver.get_state() == Diver.DiverState.DRIVING_SUBMARINE || diver.get_state() == Diver.DiverState.DRIVING_SUBMARINE:
		return
	
	if is_climbing_ladder:
		input_vector = get_ladder_input_vector()
	elif (diver.get_state() == Diver.DiverState.IN_GRAVITY_AREA or diver.get_state() == Diver.DiverState.IN_SUBMARINE):
		input_vector = get_walking_input_vector()
	else:
		input_vector = get_input_vector()
	
	if is_in_ladder_area && Input.is_action_just_pressed("interact"):
		is_climbing_ladder = !is_climbing_ladder
	
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

func get_ladder_input_vector() -> Vector2:
	input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("right"):
		input_vector += Vector2.RIGHT
	if Input.is_action_pressed("left"):
		input_vector += Vector2.LEFT
	if Input.is_action_pressed("up"):
		input_vector += Vector2.UP
	if Input.is_action_pressed("down"):
		input_vector += Vector2.DOWN
	
	if input_vector.length_squared() == 0:
		return Vector2.ZERO
	return Util.angle_to_vector_radians(input_vector.angle() + ladder.global_rotation, 1)

func get_walking_input_vector() -> Vector2:
	input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("right"):
		input_vector += Vector2.RIGHT
	if Input.is_action_pressed("left"):
		input_vector += Vector2.LEFT
	
	return input_vector

## This is mostly a workaround for now until the bug with getting the mouse 
## position inside a viewport gets fixed
func get_mouse_input_vector() -> Vector2:
	return (Vector2(DisplayServer.mouse_get_position()) - Vector2(960, 540)).normalized()

func update_current_angle(delta: float) -> void:
	if is_in_gravity_area:
		current_angle = Util.better_angle_lerp(current_angle, Vector2.UP.angle(), 0.4, delta)
		return
	
	if input_vector != Vector2.ZERO:
		var input_angle = input_vector.angle()
		current_angle = Util.better_angle_lerp(current_angle, input_angle, 0.1, delta)

func update_movement_velocity(delta: float):
	velocity = velocity * 0.97
	
	if is_climbing_ladder:
		diver.global_rotation = ladder.global_rotation
		if input_vector.length_squared() > 0:
			velocity.x += input_vector.x * 3 * delta * 60
			velocity.y += input_vector.y * 3 * delta * 60
		else:
			velocity = Vector2.ZERO
	elif is_in_gravity_area:
		diver.rotation = 0
		velocity.y += 5 * delta * 60
		if input_vector.length_squared() > 0:
			velocity.x += input_vector.x * 3 * delta * 60
		else:
			velocity.x = 0
	
	elif input_vector != Vector2.ZERO: 
		velocity += Util.angle_to_vector_radians(current_angle, CONST_ACCEL * delta)
	
	if Input.is_action_just_pressed("move"):
		velocity += Util.angle_to_vector_radians(current_angle, TAP_ACCEL * delta)
		boosted.emit()
	
	# Clamp velocity to MAX_SPEED
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED

func knockback(direction: Vector2) -> void:
	velocity += direction * knockback_velocity

func get_velocity() -> Vector2:
	return self.velocity

func get_current_angle() -> float:
	return self.current_angle

func _on_general_detection_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("gravity_areas"):
		diver.set_state(Diver.DiverState.IN_GRAVITY_AREA)
		is_in_gravity_area = true
	if area.is_in_group("submarine_area"):
		diver.set_state(Diver.DiverState.IN_SUBMARINE)
		is_in_gravity_area = true
	if area.is_in_group("research_station_area") && Global.godot_steam_abstraction && saveable_timer.time_left <= 0:
		is_in_research_station = true
		if spawned_in_research_station:
			Global.save_load_framework.save_state()
		else:
			spawned_in_research_station = true
	if area.is_in_group("ladder_area"):
		is_in_ladder_area = true
		ladder = area

func _on_general_detection_box_area_exited(area: Area2D) -> void:
	if area.is_in_group("gravity_areas") or area.is_in_group("submarine_area"):
		diver.set_state(Diver.DiverState.SWIMMING)
		is_in_gravity_area = false
	if area.is_in_group("research_station_area"):
		is_in_research_station = false
	if area.is_in_group("ladder_area"):
		is_in_ladder_area = false
		if is_climbing_ladder:
			is_climbing_ladder = false
			velocity = velocity/2
		ladder = null
