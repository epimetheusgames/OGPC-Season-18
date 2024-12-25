# Base class for any weapon
## Owned by: kaitaobenson

class_name Weapon
extends Node2D

var diver: Diver
var enabled: bool = false

var hand1_pos: Vector2
var hand2_pos: Vector2

var mouse_pos: Vector2

func _process(delta: float) -> void:
	_process_weapon(delta)

func _process_weapon(delta: float) -> void:
	hand1_pos = diver.diver_animation.get_hand1_position()
	hand1_pos = diver.diver_animation.get_hand2_position()
	
	mouse_pos = get_global_mouse_position()
