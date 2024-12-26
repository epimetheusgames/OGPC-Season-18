# Base class for any weapon
## Owned by: kaitaobenson

class_name Weapon
extends Node2D

var diver: Diver

var hand1_pos: Vector2
var hand2_pos: Vector2

var mouse_pos: Vector2

func _process(delta: float) -> void:
	hand1_pos = diver.diver_animation.get_hand1_position()
	hand1_pos = diver.diver_animation.get_hand2_position()
	
	mouse_pos = get_global_mouse_position()

func attack() -> void:
	pass  # Override
