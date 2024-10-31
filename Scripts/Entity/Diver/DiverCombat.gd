## Diver combat system.
class_name DiverCombat
extends Node2D

var weapons: Array[Weapon] = []


func add_weapon(scene: PackedScene) -> void:
	var new_weapon = scene.instantiate()
	add_child(new_weapon)

func set_weapon()
