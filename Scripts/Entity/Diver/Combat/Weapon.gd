# Base class for any weapon
## Owned by: kaitaobenson

class_name Weapon
extends Node2D

@export var use_hand1: bool = false
@export var use_hand2: bool = false

var diver: Diver

var enabled: bool = false

var head_pos: Vector2
var mouse_pos: Vector2

func _process(delta: float) -> void:
	head_pos = diver.diver_animation.get_head_position()
	mouse_pos = get_global_mouse_position()

func get_hand1_pos() -> Vector2:
	return Vector2.ZERO  # Override

func get_hand2_pos() -> Vector2:
	return Vector2.ZERO  # Override

func attack() -> void:
	pass  # Override

func perform_attack() -> void:
	pass  # Override
