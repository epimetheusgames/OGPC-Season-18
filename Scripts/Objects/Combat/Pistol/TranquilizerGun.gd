# Owned by carsonetb

"""
class_name TranquilizerGun
extends Weapon

var combat: DiverCombat
var diver: Diver
var flipped := false
var shooting := false

@export var bullet_velocity = 20

@onready var loaded_bullet = preload("res://Scenes/TSCN/Objects/PistolProjectile.tscn")

func _ready() -> void:
	combat = get_parent()
	diver = combat.diver

func _process(delta: float) -> void:
	var mouse_position := get_global_mouse_position()
	
	global_position = hand1_pos
	global_rotation = combat.diver.diver_animation.get_node("Skeleton/Torso/UpperArm2/Forearm2").global_position.angle_to_point(hand_primary)
	combat.move_hand_toward_mouse("right")
	
	if !$TranquilizerGunSprite.animation == "Flip":
		if (rad_to_deg(global_rotation) < -90 || rad_to_deg(global_rotation) > 90) && !flipped:
			$TranquilizerGunSprite.play("Flip")
		elif !(rad_to_deg(global_rotation) < -90 || rad_to_deg(global_rotation) > 90) && flipped:
			$TranquilizerGunSprite.play("Flip")
	
	if !$TranquilizerGunSprite.animation == "Shoot":
		shooting = false

func attack() -> void:
	if !$TranquilizerGunSprite.animation == "Shoot" && !shooting:
		$TranquilizerGunSprite.play("Shoot")
		
		shooting = true
		if diver._is_node_owner() || !Global.is_multiplayer:
			spawn_bullet($BulletShootPosition.global_position, (Vector2.from_angle(global_rotation) * bullet_velocity * 60 + diver.velocity), global_rotation + PI / 2.0)
			Global.godot_steam_abstraction.run_remote_function(self, "spawn_bullet", [$BulletShootPosition.global_position, (Vector2.from_angle(global_rotation) * bullet_velocity * 60 + diver.velocity), global_rotation + PI / 2.0])

func spawn_bullet(pos: Vector2, velocity: Vector2, rot: float) -> void:
	var bullet = loaded_bullet.instantiate()
	diver.get_parent().add_child(bullet, true)
	bullet.linear_velocity = velocity
	bullet.rotation = rot
	bullet.global_position = pos

func _on_tranquilizer_gun_sprite_animation_finished() -> void:
	if $TranquilizerGunSprite.animation == "Shoot":
		shooting = false
		$TranquilizerGunSprite.play("Idle")
	
	if $TranquilizerGunSprite.animation != "Flip":
		return
		
	if !flipped:
		flipped = true
		$TranquilizerGunSprite.scale.y = -1
	else:
		flipped = false
		$TranquilizerGunSprite.scale.y = 1
	
	$TranquilizerGunSprite.play("Idle")
"""
