# Owned by carsonetb
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
	
	global_position = hand_primary
	global_rotation = combat.diver.diver_animation.get_node("Skeleton/Torso/UpperArm2/Forearm2").global_position.angle_to_point(hand_primary)
	combat.move_hand_toward_mouse("right")
	
	if !$TranquilizerGunSprite.animation == "Flip":
		if (rad_to_deg(global_rotation) < -90 || rad_to_deg(global_rotation) > 90) && !flipped:
			$TranquilizerGunSprite.play("Flip")
		elif !(rad_to_deg(global_rotation) < -90 || rad_to_deg(global_rotation) > 90) && flipped:
			$TranquilizerGunSprite.play("Flip")

func attack() -> void:
	if !$TranquilizerGunSprite.animation == "Shoot" && !shooting:
		$TranquilizerGunSprite.play("Shoot")
		
		shooting = true
		var bullet = loaded_bullet.instantiate()
		diver.get_parent().add_child(bullet, true)
		bullet.linear_velocity  = (Vector2.from_angle(global_rotation) * bullet_velocity * 60 + diver.velocity)
		bullet.global_position = $BulletShootPosition.global_position

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
