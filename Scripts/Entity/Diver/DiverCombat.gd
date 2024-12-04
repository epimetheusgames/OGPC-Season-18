## Diver combat system.
# Owned by kaitaobenson
class_name DiverCombat
extends Node2D

@onready var diver: Diver = get_parent()

const preloaded_weapons := {
	"Speargun": preload("res://Scenes/TSCN/Objects/Weapons/Speargun.tscn"),
	"Knife": preload("res://Scenes/TSCN/Objects/Weapons/Knife.tscn"),
	"TranquilizerGun": preload("res://Scenes/TSCN/Objects/Weapons/TranquilizerGun.tscn"),
}

var right_hand_weapon: Weapon
var left_hand_weapon: Weapon
var both_hands_weapon: Weapon

func _ready():
	add_weapon("TranquilizerGun", "right")

func _process(delta: float) -> void:
	if left_hand_weapon:
		left_hand_weapon.hand_primary = diver.diver_animation.get_hand1_position()
		left_hand_weapon.hand_secondary = diver.diver_animation.get_hand2_position()
	if right_hand_weapon:
		right_hand_weapon.hand_secondary = diver.diver_animation.get_hand1_position()
		right_hand_weapon.hand_primary = diver.diver_animation.get_hand2_position()
	if both_hands_weapon:
		both_hands_weapon.hand_primary = diver.diver_animation.get_hand1_position()
		both_hands_weapon.hand_secondary = diver.diver_animation.get_hand2_position()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		right_hand_weapon.attack()
	if Input.is_action_just_pressed("secondary_attack"):
		left_hand_weapon.attack()

func move_hand_toward_mouse(hand: String) -> void:
	if hand == "left":
		diver.diver_animation.arm_target1.global_position = get_global_mouse_position()
	if hand == "right":
		diver.diver_animation.arm_target2.global_position = get_global_mouse_position()

func add_weapon(weapon_name: String, hand: String) -> void:
	var new_weapon = preloaded_weapons[weapon_name].instantiate()
	add_child(new_weapon)
	
	if hand == "left":
		left_hand_weapon = new_weapon
	elif hand == "right":
		right_hand_weapon = new_weapon
	elif hand == "both":
		both_hands_weapon = new_weapon
		left_hand_weapon = null
		right_hand_weapon = null
	else:
		print("ERROR: Invalid hand for new_weapon call. Hand was " + hand + ". Printing stack.")
		print_stack()

func remove_weapon(hand: String) -> void:
	if hand == "left":
		left_hand_weapon = null
	elif hand == "right":
		right_hand_weapon = null
	elif hand == "both":
		both_hands_weapon = null
	else:
		print("ERROR: Invalid hand for remove_weapon call. Printing stack.")
