## Diver movement system.
# Owned by: kaitaobenson

class_name DiverMovement
extends Node2D

# Swim
const SWIM_BASE_SPEED: float = 250.0
const SWIM_AIMING_SPEED: float = 100.0
const SWIM_ACCEL: float = 10.0
const SWIM_MAX_SPEED: float = 650.0
var speed: float = SWIM_BASE_SPEED

# Walk
const WALK_SPEED: float = 400.0
const GRAVITY: float = 30.0

# Ladder
const LADDER_CLIMB_SPEED: float = 30.0

var is_in_gravity_area: bool = false
var spawned_in_research_station: bool = false
var is_in_research_station: bool = true
var is_in_ladder_area: bool = false
var is_climbing_ladder: bool = false

var is_aiming_weapon: bool = false
var is_knocked_back: bool = false


var ladder: Area2D = null

@onready var saveable_timer := get_tree().create_timer(0.5)
@onready var diver: Diver = get_parent()
@onready var down_raycast: RayCast2D = $"DownRaycast"

@onready var footstep_sounds: AudioVariationPlayer = $"../Sound/FootstepSounds"
@onready var bubble_sounds: AudioStreamPlayer2D = $"../Sound/BubbleSounds"

var is_boosting: bool = false

var input_vector: Vector2
var input_angle: float


func _physics_process(delta: float) -> void:
	if (Global.is_multiplayer && !diver._is_node_owner()) || diver.get_state() == Diver.DiverState.DRIVING_SUBMARINE || diver.get_state() == Diver.DiverState.DRIVING_SUBMARINE:
		return
	
	if is_in_ladder_area && Input.is_action_just_pressed("interact"):
		is_climbing_ladder = !is_climbing_ladder
	
	if Input.is_action_pressed("boost") && !is_aiming_weapon && !is_climbing_ladder && !is_in_gravity_area:
		speed += SWIM_ACCEL
		bubble_sounds.volume_db = -4.0
		is_boosting = true
	else:
		speed -= SWIM_ACCEL
		bubble_sounds.volume_db = -100.0
		is_boosting = false
	
	speed = clamp(speed, SWIM_BASE_SPEED, SWIM_MAX_SPEED)
	
	input_vector = get_wasd_input_vector()
	
	if input_vector.length() > 0:
		input_angle = input_vector.angle() + PI/2
	
	
	if is_climbing_ladder:
		# Ladder
		diver.global_rotation = ladder.global_rotation
		if input_vector.length_squared() > 0:
			diver.velocity.x += input_vector.x * LADDER_CLIMB_SPEED * delta * 60
			diver.velocity.y += input_vector.y * LADDER_CLIMB_SPEED * delta * 60
		else:
			diver.velocity = Vector2.ZERO
		
	elif is_in_gravity_area:
		# Walk
		diver.global_rotation = 0
		
		if down_raycast.is_colliding():
			diver.velocity.y = 0.1
		else:
			diver.velocity.y += GRAVITY * delta * 60
		
		if input_vector.length_squared() > 0:
			diver.velocity.x = input_vector.x * WALK_SPEED * delta * 60
			footstep_sounds.play_random()
		else:
			diver.velocity.x = 0
	
	else:
		# Swim
		if !is_knocked_back:
			if is_aiming_weapon:
				# Move slow while aiming
				diver.global_rotation += angle_difference(diver.global_rotation, input_angle) * 0.05
				var vel = Vector2.UP.rotated(diver.global_rotation) * SWIM_AIMING_SPEED
				diver.velocity = diver.velocity.lerp(vel, 0.5)
			
			elif input_vector.length() > 0:
				diver.global_rotation += angle_difference(diver.global_rotation, input_angle) * 0.05
				var vel = Vector2.UP.rotated(diver.global_rotation) * speed
				diver.velocity = diver.velocity.lerp(vel, 0.5)
	
	diver.velocity *= 0.98

func knockback(force: Vector2) -> void:
	is_knocked_back = true
	diver.velocity = force
	await get_tree().create_timer(0.7).timeout
	is_knocked_back = false

func get_wasd_input_vector() -> Vector2:
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("right"):
		input_vector += Vector2.RIGHT
	if Input.is_action_pressed("left"):
		input_vector += Vector2.LEFT
	if Input.is_action_pressed("up"):
		input_vector += Vector2.UP
	if Input.is_action_pressed("down"):
		input_vector += Vector2.DOWN
	
	return input_vector


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
			diver.velocity = diver.velocity/2
		ladder = null
