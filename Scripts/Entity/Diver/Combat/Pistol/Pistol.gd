## Semi-auto pistol (tranquilizer?)
# Owned by carsonetb

class_name Pistol
extends Gun

@onready var pistol_sprite: AnimatedSprite2D = $"PistolSprite"
@onready var emit_point: Node2D = $"EmitPoint"
@onready var cone_of_fire: ConeOfFire = $"ConeOfFire"

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
	
	var spread: float = get_movement_factor()
	cone_of_fire.increase_spread(spread)

func get_gun_position() -> Vector2:
	return hand1_pos

func get_gun_rotation() -> float:
	var mouse_pos: Vector2 = get_global_mouse_position()
	return hand1_pos.angle_to_point(mouse_pos)

func attack() -> void:
	if !pistol_sprite.animation == "Shoot" && !shooting:
		pistol_sprite.play("Shoot")
		
		shooting = true
		
		if !Global.is_multiplayer || diver._is_node_owner():
			
			var bullet: BaseBullet = bullet_scene.instantiate()
			add_child(bullet)
			
			bullet.global_position = emit_point.global_position
			bullet.fire(global_rotation)
			
			# Wtf is this line my g
			#Global.godot_steam_abstraction.run_remote_function(self, "spawn_bullet", [$BulletShootPosition.global_position, (Vector2.from_angle(global_rotation) * bullet_velocity * 60 + diver.velocity), global_rotation + PI / 2.0])

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
