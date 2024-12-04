## Base class for weapons
class_name Weapon
extends Node2D

var hand_primary: Vector2 = Vector2(0, 0)
var hand_secondary: Vector2 = Vector2(0, 0)

var enabled: bool = false

func attack() -> void:
	pass

func set_hand1(pos: Vector2) -> void:
	hand_primary = pos
func set_hand2(pos: Vector2) -> void:
	hand_secondary = pos
