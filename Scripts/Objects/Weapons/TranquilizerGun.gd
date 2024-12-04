class_name TranquilizerGun
extends Weapon

var combat: DiverCombat

func _ready() -> void:
	combat = get_parent()

func _process(delta: float) -> void:
	var mouse_position := get_global_mouse_position()
	
	global_position = hand_primary
	global_rotation = combat.diver.diver_animation.get_node("Skeleton/Torso/UpperArm2/Forearm2").global_position.angle_to_point(hand_primary)
	combat.move_hand_toward_mouse("right")

func attack() -> void:
	$TranquilizerGunSprite.play("Shoot")
	# Shoot bullet code here
