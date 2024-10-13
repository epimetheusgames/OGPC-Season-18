class_name Diver
extends Entity

@onready var diver_movement: DiverMovement = $"Movement"
@onready var diver_animation: DiverAnimation = $"Animation"
@onready var diver_combat: DiverCombat = $"Combat"
@onready var diver_flashlight: DiverFlashlight = $"Flashlight"

func _physics_process(delta: float):
	velocity = diver_movement.get_velocity()
	
	var target_angle: float
	if !($Movement/RightWallRaycast.get_collider() && $Movement/LeftWallRaycast.get_collider()):
		target_angle = velocity.angle() + PI/2
	else:
		# Fancy math to make the player do good stuff in tight spaces.
		var forward_angle: float = $Movement/RightWallRaycast.get_collision_normal().angle() + PI
		var offset_angle: float = clamp(angle_difference(rotation, velocity.angle() + PI / 2) * 0.3, -0.4, 0.4)
		target_angle = forward_angle + offset_angle
	var angle_diff: float = angle_difference(rotation, target_angle)
	rotation += clamp(angle_diff * 0.1, -0.1, 0.1)
	
	move_and_slide()
	
	if Input.is_action_just_pressed("attack"):
		diver_combat.attack()

func get_diver_movement() -> DiverMovement:
	return diver_movement
