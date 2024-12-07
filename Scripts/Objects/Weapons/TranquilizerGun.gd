# Owned by carsonetb
class_name TranquilizerGun
extends Weapon

var combat: DiverCombat
var flipped := false

func _ready() -> void:
	combat = get_parent()

func _process(delta: float) -> void:
	var mouse_position := get_global_mouse_position()
	
	global_position = hand_primary
	global_rotation = combat.diver.diver_animation.get_node("Skeleton/Torso/UpperArm2/Forearm2").global_position.angle_to_point(hand_primary)
	combat.move_hand_toward_mouse("right")
	
	print(rad_to_deg(global_rotation))
	if !$TranquilizerGunSprite.animation == "Flip":
		if (rad_to_deg(global_rotation) < -90 || rad_to_deg(global_rotation) > 90) && !flipped:
			$TranquilizerGunSprite.play("Flip")
		elif !(rad_to_deg(global_rotation) < -90 || rad_to_deg(global_rotation) > 90) && flipped:
			$TranquilizerGunSprite.play("Flip")

func attack() -> void:
	$TranquilizerGunSprite.play("Shoot")
	# Shoot bullet code here

func _on_tranquilizer_gun_sprite_animation_finished() -> void:
	if $TranquilizerGunSprite.animation != "Flip":
		return
		
	if !flipped:
		flipped = true
		$TranquilizerGunSprite.scale.y = -1
	else:
		flipped = false
		$TranquilizerGunSprite.scale.y = 1
	
	$TranquilizerGunSprite.play("Idle")
