## For state machine
# Owned by: kaibenson

class_name State
extends Node

var enemy: Enemy

func init() -> void:
	$"Timer".connect("timeout", done)

func enter() -> void:
	pass

func exit() -> void:
	pass

func process_input(event: InputEvent) -> State:
	return null

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	return null

func done() -> void:
	enemy = enemy as Jellyfish
	var target: Vector2 = enemy.get_global_mouse_position()
	enemy.boost(300, 2, target)
