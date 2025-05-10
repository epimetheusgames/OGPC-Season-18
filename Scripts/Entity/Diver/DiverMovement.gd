class_name DiverMovement
extends Node2D

# Triggers when the diver moves, exists for tutorial purposes
signal diver_moved

# Swim
const SWIM_BASE_SPEED := 350.0
const SWIM_AIMING_SPEED := 150.0
const SWIM_ACCEL := 10.0
const SWIM_MAX_SPEED := 700.0

# Walk
const WALK_SPEED := 400.0
const GRAVITY := 30.0

# Ladder
const LADDER_CLIMB_SPEED := 30.0

# States
var is_in_gravity_area := false
var is_in_research_station := true
var is_in_ladder_area := false
var is_climbing_ladder := false
var is_knocked_back := false
var is_boosting := false
var is_aiming_weapon := false
var spawned_in_research_station := false

# References
var ladder: Area2D = null
@onready var diver: Diver = get_parent()
@onready var down_raycast: RayCast2D = $"DownRaycast"
@onready var footstep_sounds: AudioVariationPlayer = $"../Sound/FootstepSounds"
@onready var bubble_sounds: AudioStreamPlayer2D = $"../Sound/BubbleSounds"
@onready var saveable_timer := get_tree().create_timer(0.5)

# Input
var input_vector := Vector2.ZERO
var input_angle := 0.0
var speed := SWIM_BASE_SPEED

# --- Main Process ---
func _physics_process(delta: float) -> void:
	if Global.is_multiplayer and not diver._is_node_owner():
		return
	if diver.get_state() in [Diver.DiverState.DRIVING_SUBMARINE]:
		return
	
	handle_ladder_toggle()
	handle_boost()
	
	input_vector = get_wasd_input_vector()
	if input_vector.length() > 0:
		input_angle = input_vector.angle() + PI / 2
		diver_moved.emit()
	
	if is_climbing_ladder:
		handle_ladder_movement(delta)
		diver_moved.emit()
	elif is_in_gravity_area:
		handle_walk_movement(delta)
		diver_moved.emit()
	else:
		handle_swim_movement(delta)
		diver_moved.emit()
	
	if is_in_ladder_area && !Global.pressable_buttons_panel.has("Use Ladder"):
		Global.pressable_buttons_panel.buttons.append(PressableButtonsPanel.ButtonPress.create("Use Ladder", "E"))
	elif !is_in_ladder_area:
		Global.pressable_buttons_panel.remove("Use Ladder")
	
	diver.velocity *= 0.98

func handle_boost() -> void:
	if Input.is_action_pressed("boost") && !is_aiming_weapon && !is_climbing_ladder && !is_in_gravity_area:
		speed += SWIM_ACCEL
		bubble_sounds.volume_db = -4.0
		is_boosting = true
	else:
		speed -= SWIM_ACCEL
		bubble_sounds.volume_db = -100.0
		is_boosting = false
	speed = clamp(speed, SWIM_BASE_SPEED, SWIM_MAX_SPEED)

func handle_ladder_toggle() -> void:
	if is_in_ladder_area and Input.is_action_just_pressed("interact"):
		is_climbing_ladder = !is_climbing_ladder

# Movement

func handle_ladder_movement(delta: float) -> void:
	diver.global_rotation = ladder.global_rotation
	if input_vector.length_squared() > 0:
		diver.velocity.x += input_vector.x * LADDER_CLIMB_SPEED * delta * 60
		diver.velocity.y += input_vector.y * LADDER_CLIMB_SPEED * delta * 60
	else:
		diver.velocity = Vector2.ZERO

func handle_walk_movement(delta: float) -> void:
	diver.global_rotation = 0
	diver.velocity.y += GRAVITY * delta * 60 if not down_raycast.is_colliding() else 0.1
	if input_vector.length_squared() > 0:
		diver.velocity.x = input_vector.x * WALK_SPEED * delta * 60
		footstep_sounds.play_random()
	else:
		diver.velocity.x = 0

func handle_swim_movement(delta: float) -> void:
	if is_knocked_back:
		return

	if is_aiming_weapon:
		diver.global_rotation += angle_difference(diver.global_rotation, input_angle) * 0.05
		if input_vector.length() > 0:
			var vel := Vector2.UP.rotated(diver.global_rotation) * SWIM_AIMING_SPEED
			diver.velocity = diver.velocity.lerp(vel, 0.5)
		else:
			diver.velocity = diver.velocity.lerp(Vector2.ZERO, 0.5)
	
	elif input_vector.length() > 0:
		diver.global_rotation += angle_difference(diver.global_rotation, input_angle) * 0.05
		var vel := Vector2.UP.rotated(diver.global_rotation) * speed
		diver.velocity = diver.velocity.lerp(vel, 0.5)

# Util
func get_wasd_input_vector() -> Vector2:
	var vec := Vector2.ZERO
	if Input.is_action_pressed("right"): vec.x += 1
	if Input.is_action_pressed("left"):  vec.x -= 1
	if Input.is_action_pressed("up"):    vec.y -= 1
	if Input.is_action_pressed("down"):  vec.y += 1
	return vec.normalized()

func knockback(force: Vector2) -> void:
	is_knocked_back = true
	diver.velocity = force
	await get_tree().create_timer(0.7).timeout
	is_knocked_back = false

# Area Detection
func _on_general_detection_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("gravity_areas"):
		diver.set_state(Diver.DiverState.IN_GRAVITY_AREA)
		is_in_gravity_area = true
	elif area.is_in_group("submarine_area"):
		diver.set_state(Diver.DiverState.IN_SUBMARINE)
		is_in_gravity_area = true
	elif area.is_in_group("research_station_area") and Global.godot_steam_abstraction and saveable_timer.time_left <= 0:
		is_in_research_station = true
		if spawned_in_research_station && !Global.is_multiplayer:
			Global.save_load_framework.save_state()
		else:
			spawned_in_research_station = true
	elif area.is_in_group("ladder_area"):
		is_in_ladder_area = true
		ladder = area

func _on_general_detection_box_area_exited(area: Area2D) -> void:
	if area.is_in_group("gravity_areas") or area.is_in_group("submarine_area"):
		diver.set_state(Diver.DiverState.SWIMMING)
		is_in_gravity_area = false
	elif area.is_in_group("research_station_area"):
		is_in_research_station = false
	elif area.is_in_group("ladder_area"):
		is_in_ladder_area = false
		if is_climbing_ladder:
			is_climbing_ladder = false
			diver.velocity *= 0.5
		ladder = null
