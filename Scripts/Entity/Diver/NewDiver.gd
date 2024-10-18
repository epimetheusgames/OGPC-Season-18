class_name Diver
extends Entity

@onready var diver_movement: DiverMovement = $"Movement"
@onready var diver_animation: DiverAnimation = $"Animation"
@onready var diver_combat: DiverCombat = $"Combat"
@onready var diver_flashlight: DiverFlashlight = $"Flashlight"

func _physics_process(delta: float):
	velocity = diver_movement.get_velocity()
	
	# TODO: Move this all to the animation script.
	var target_angle: float
	if !($Movement/RightWallRaycast.get_collider() && $Movement/LeftWallRaycast.get_collider()):
		target_angle = velocity.angle() + PI/2
	else:
		# Fancy math to make the player do good stuff in tight spaces. TODO: Add IK to walls here
		# to make it look like we're crawling.
		var forward_angle: float = $Movement/RightWallRaycast.get_collision_normal().angle() + PI
		var offset_angle: float = clamp(angle_difference(rotation, velocity.angle() + PI / 2) * 0.3, -0.4, 0.4)
		target_angle = forward_angle + offset_angle
		
		# IK stuff, looks pretty goofy.
		var right_ik_multiplier = -40 + fmod(position.length(), 140)
		var left_ik_multiplier = -40 + fmod(position.length() + 70, 140)
		var right_arm_offset = Util.angle_to_vector($Movement/RightWallRaycast.get_collision_normal().angle() + PI / 2, right_ik_multiplier)
		var left_arm_offset = Util.angle_to_vector($Movement/LeftWallRaycast.get_collision_normal().angle() + PI / 2, -left_ik_multiplier)
		diver_animation.arm_target1.global_position += ($Movement/RightWallRaycast.get_collision_point() + right_arm_offset - diver_animation.arm_target1.global_position) * 0.1
		diver_animation.arm_target2.global_position += ($Movement/LeftWallRaycast.get_collision_point() + left_arm_offset - diver_animation.arm_target2.global_position) * 0.1
		
	var angle_diff: float = angle_difference(rotation, target_angle)
	rotation += clamp(angle_diff * 0.1, -0.1, 0.1)
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision && collision.get_collider() is CharacterBody2D:
			collision.get_collider().velocity = -collision.get_normal() * 5
	
	move_and_slide()
	
	if Input.is_action_just_pressed("attack"):
		diver_combat.attack()

func get_diver_movement() -> DiverMovement:
	return diver_movement
