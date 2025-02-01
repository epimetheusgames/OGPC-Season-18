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
	
	if Global.godot_steam_abstraction && Global.is_multiplayer && !diver._is_node_owner():
		return
	
	#combat.move_hand_toward_mouse("right")
	
	if !pistol_sprite.animation == "Flip":
		if (global_rotation < -PI/2 || global_rotation > PI/2) && !flipped:
			pistol_sprite.play("Flip")
		elif !(global_rotation < -PI/2 || global_rotation > PI/2) && flipped:
			pistol_sprite.play("Flip")
	
	if !pistol_sprite.animation == "Shoot":
		shooting = false
	
	if Global.godot_steam_abstraction && !Global.is_multiplayer || diver._is_node_owner():
		Global.godot_steam_abstraction.sync_var(self, "position")
		Global.godot_steam_abstraction.sync_var(self, "rotation")

func perform_attack() -> void:
	if !pistol_sprite.animation == "Shoot" && !shooting:
		pistol_sprite.play("Shoot")
		
		shooting = true
		
		if Global.godot_steam_abstraction && !Global.is_multiplayer || diver._is_node_owner():
			var bullet: BaseBullet = bullet_scene.instantiate()
			add_child(bullet)
			
			bullet.global_position = emit_point.global_position
			var shot_angle: float = cone_of_fire.get_shot_angle()
			bullet.fire(shot_angle)
			
			# Maybe this doesn't work??? Shouldn't the player names be different on seperate clients?
			Global.godot_steam_abstraction.run_remote_function(self, "spawn_bullet", [bullet.global_position, shot_angle])

func spawn_bullet(pos: Vector2, shot_angle: float) -> void:
	var bullet: BaseBullet = bullet_scene.instantiate()
	add_child(bullet)
	
	bullet.global_position = pos
	bullet.fire(shot_angle)

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
