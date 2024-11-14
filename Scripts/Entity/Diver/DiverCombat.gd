## Diver combat system.
class_name DiverCombat
extends Node2D

@onready var diver: Diver = get_parent()

var weapons: Array[Weapon] = [
	null,
	null,
	null,
]
var enabled_weapon: Weapon

var speargun: PackedScene = preload("res://Scenes/TSCN/Objects/Weapons/Speargun.tscn")

func _ready() -> void:
	add_weapon(speargun)
	pass
	#set_weapon(0)

func _process(delta: float) -> void:
	pass
	#enabled_weapon.hand1 = diver.diver_animation.get_hand1_position()
	#enabled_weapon.hand2 = diver.diver_animation.get_hand2_position()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		pass
		#enabled_weapon.attack()


func add_weapon(scene: PackedScene) -> void:
	var new_weapon = scene.instantiate()
	
	if new_weapon is Weapon:
		add_child(new_weapon)
		weapons.append(new_weapon)

func remove_weapon(index: int) -> void:
	weapons.remove_at(index)

# Enables weapon at index
func set_weapon(index: int):
	if index < 0 || index > weapons.size() - 1:
		enabled_weapon
	enabled_weapon = weapons[index]
