# Base class for any weapon
## Owned by: kaitaobenson

class_name Weapon
extends Node2D

@export var use_hand1: bool = false
@export var use_hand2: bool = false

var enabled: bool = false

var head_pos: Vector2
var mouse_pos: Vector2

func _process(_delta: float) -> void:
	head_pos = Global.player.diver_animation.arm1.get_parent().global_position
	mouse_pos = get_global_mouse_position()

func get_hand1_pos() -> Vector2:
	return Vector2.ZERO  # Override

func get_hand2_pos() -> Vector2:
	return Vector2.ZERO  # Override

func attack() -> void:
	pass  # Override

func perform_attack(remote=false, node_name="") -> void:
	if !remote:
		if Global.godot_steam_abstraction && Global.is_multiplayer && !Global.player._is_node_owner():
			print("WARNING: Tried to perform attack but is not the owner of this diver. Check your logic. Printing stack.")
			print_stack()
			return
		
		if Global.godot_steam_abstraction:
			Global.godot_steam_abstraction.run_remote_function(self, "perform_attack", [true, node_name])
