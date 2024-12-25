## Semi-auto pistol (tranquilizer?)
# Owned by carsonetb

class_name Pistol
extends Gun

@onready var pistol_sprite: AnimatedSprite2D = $"PistolSprite"
@onready var emit_point: Node2D = $"EmitPoint"

var flipped: bool = false
var shooting: bool = false

func _process(delta: float) -> void:
	super(delta)
	global_position = get_gun_position()
	global_rotation = get_gun_rotation()
	#combat.move_hand_toward_mouse("right")
	
	if !pistol_sprite.animation == "Flip":
		if (global_rotation < -PI/2 || global_rotation > PI/2) && !flipped:
			pistol_sprite.play("Flip")
		elif !(global_rotation < -PI/2 || global_rotation > PI/2) && flipped:
			pistol_sprite.play("Flip")
	
	if !pistol_sprite.animation == "Shoot":
		shooting = false

func get_gun_position() -> Vector2:
	return hand1_pos

func get_gun_rotation() -> float:
	var forearm: Node2D = diver.diver_animation.get_node("Skeleton/Torso/UpperArm2/Forearm2")
	return forearm.global_position.angle_to_point(hand1_pos)

func attack() -> void:
	if !pistol_sprite.animation == "Shoot" && !shooting:
		pistol_sprite.play("Shoot")
		
		shooting = true
		
		if diver._is_node_owner() || !Global.is_multiplayer:
			var velocity: Vector2 = Vector2.from_angle(global_rotation) * 10 * 60 + diver.velocity
			var rot: float = global_rotation + PI/2
			
			spawn_bullet(emit_point.global_position, velocity, rot)
			
			# Wtf is this line my g
			#Global.godot_steam_abstraction.run_remote_function(self, "spawn_bullet", [$BulletShootPosition.global_position, (Vector2.from_angle(global_rotation) * bullet_velocity * 60 + diver.velocity), global_rotation + PI / 2.0])

func spawn_bullet(pos: Vector2, velocity: Vector2, rot: float) -> void:
	var bullet = bullet_scene.instantiate()
	diver.get_parent().add_child(bullet, true)
	bullet.linear_velocity = velocity
	bullet.rotation = rot
	bullet.global_position = pos

func _on_tranquilizer_gun_sprite_animation_finished() -> void:
	if pistol_sprite.animation == "Shoot":
		shooting = false
		pistol_sprite.play("Idle")
	
	if pistol_sprite.animation != "Flip":
		return
		
	if !flipped:
		flipped = true
		pistol_sprite.scale.y = -1
	else:
		flipped = false
		pistol_sprite.scale.y = 1
	
	pistol_sprite.play("Idle")
