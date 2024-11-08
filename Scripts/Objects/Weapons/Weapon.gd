## Base class for weapons
class_name Weapon
extends Node2D

var hand1: Vector2 = Vector2(0, 0)
var hand2: Vector2 = Vector2(0, 0)

var enabled: bool = false

func attack() -> void:
	pass

func set_hand1(pos: Vector2) -> void:
	hand1 = pos
func set_hand2(pos: Vector2) -> void:
	hand2 = pos
