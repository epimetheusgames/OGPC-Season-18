# Coded by Xavier

class_name SubmarineWeaponSlot
extends Node2D

@export var attached_weapon : PackedScene

var in_interaction_area : bool = false
var is_being_operated : bool = false

func _ready() -> void:
	if attached_weapon != null:
		var weapon : Node2D = attached_weapon.instantiate()
		add_child(weapon)
