# Coded by Xavier lol

## Submarine movement system
class_name SubmarineMovement
extends Node2D

# Tutorial stuff
signal drive_entered
signal drive_exited

const CONST_ACCEL: int = 40
const MAX_SPEED: float = 7500.0
const MAX_ROTATION: float = PI/12
const BOUNCE_VELOCITY_DECAY: float = .9

@onready var submarine : Submarine = get_parent()

var in_interaction_area : bool = false
var current_angle: float = 0.0
var target_angle: float = 0.0
var input_vector: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO

var health : float = 500.0
var invunerability_timer : Timer
var invunerability_length : float = .25
var invunerable : bool = false

var is_being_operated : bool = false

func _ready() -> void:
	invunerability_timer = Timer.new()
	invunerability_timer.one_shot = true
	add_child(invunerability_timer)
	invunerability_timer.connect("timeout", _on_invunerability_cooldown_timeout)

func _process(delta: float) -> void:
	if Global.is_multiplayer && submarine._is_node_owner():
		Global.godot_steam_abstraction.sync_var(self, "is_being_operated")

func _physics_process(delta: float) -> void:
	decay_velocity(delta)
	
	if in_interaction_area && !Global.pressable_buttons_panel.has("Operate"):
		Global.pressable_buttons_panel.buttons.append(PressableButtonsPanel.ButtonPress.create("Operate", "E"))
	elif !in_interaction_area:
		Global.pressable_buttons_panel.remove("Operate")
	
	if is_being_operated && !Global.pressable_buttons_panel.has("Shoot"):
		Global.pressable_buttons_panel.buttons.append(PressableButtonsPanel.ButtonPress.create("Shoot", "Left Mouse"))
	elif !is_being_operated:
		Global.pressable_buttons_panel.remove("Shoot")
	
	if !Global.is_multiplayer || get_parent()._is_node_owner():
		if !invunerable:
			for i in range(get_parent().get_slide_collision_count()):
				var collision = get_parent().get_slide_collision(i)
				var body = collision.get_collider()
				if body.is_in_group("environment_collision"):
					var reflection_velocity = collision.get_collider_velocity() + velocity
					var collision_normal_angle = collision.get_normal().angle()
					var new_angle = 2 * collision_normal_angle - reflection_velocity.angle() - PI
					
					velocity = Util.angle_to_vector_radians(new_angle, reflection_velocity.length() * BOUNCE_VELOCITY_DECAY)
					print("Submarine bounced with new velocity: " + str(velocity))
					
					var velocity_change : float = (reflection_velocity - velocity).length()
					$"../Hurtbox".damage(velocity_change/30, Attackbox.new())
					invunerability_timer.start(invunerability_length)
					invunerable = true
					break
			
			if Global.player.get_state() == Diver.DiverState.DRIVING_SUBMARINE:
				input_vector = get_input_vector()
				update_movement_velocity(delta * 60)
				update_current_angle(delta * 60)
				get_parent().rotation = current_angle
			## MAKE THIS APPROX = TO OR SOMETHING
		if current_angle != 0:
			update_current_angle(delta * 60)
			get_parent().rotation = current_angle
	
	if Input.is_action_just_pressed("interact"):
		if Global.player.get_state() != Diver.DiverState.DRIVING_SUBMARINE and in_interaction_area and !is_being_operated: 
			Global.player.set_state(Diver.DiverState.DRIVING_SUBMARINE)
			is_being_operated = true
			drive_entered.emit()
			$"../SubmarineWeaponSlot/SubmarineBurstWeapon".is_being_operated = true
		elif Global.player.get_state() == Diver.DiverState.DRIVING_SUBMARINE:
			Global.player.set_state(Diver.DiverState.IN_GRAVITY_AREA)
			target_angle = 0.0
			is_being_operated = false
			drive_exited.emit()
			$"../SubmarineWeaponSlot/SubmarineBurstWeapon".is_being_operated = false
			#Global.player.scale = Vector2(1,1)

func _on_invunerability_cooldown_timeout():
	invunerable = false

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_area"):
		in_interaction_area = true

func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_area"):
		in_interaction_area = false

func decay_velocity(delta : float):
	velocity = velocity * 0.95 * delta * 60

func get_input_vector() -> Vector2:
	input_vector = Vector2.ZERO
	target_angle = 0.0
	
	if Input.is_action_pressed("right"):
		input_vector.x += 1
		if !get_parent().flipped:
			get_parent().flip()
	if Input.is_action_pressed("left"):
		input_vector.x -= 1
		if get_parent().flipped:
			get_parent().flip()
	if Input.is_action_pressed("up"):
		input_vector.y -= .5
	if Input.is_action_pressed("down"):
		input_vector.y += .5
	
	var xy_product = input_vector.x * input_vector.y
	if xy_product != 0:
		target_angle = MAX_ROTATION * xy_product / abs(xy_product)
	
	return input_vector

func update_current_angle(delta: float) -> void:
	current_angle = Util.better_angle_lerp(current_angle, target_angle, 0.0025, delta)

func update_movement_velocity(delta: float):
	if input_vector.x != 0.0:
		velocity += input_vector.x * Util.angle_to_vector_radians(current_angle, CONST_ACCEL * delta)
	elif input_vector.y != 0.0:
		velocity += Vector2(0, input_vector.y) * CONST_ACCEL * delta
	
	# Clamp velocity to MAX_SPEED
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED

func get_velocity() -> Vector2:
	return self.velocity

func get_current_angle() -> float:
	return self.current_angle
