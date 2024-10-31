## Base class for weapons
class_name Weapon
extends Node2D

var hand1: Vector2 = Vector2(0, 0)
var hand2: Vector2 = Vector2(0, 0)

var enabled: bool = false

func attack() -> void:
	pass
