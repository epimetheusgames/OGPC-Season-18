class_name Spear
extends Node2D

var velocity: Vector2

var editor_offset: Vector2


func _ready() -> void:
	editor_offset = position
	print(position)

func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	
	velocity * 0.9

# Negative power will go backwards
func move_forwards(power: float) -> void:
	top_level = true
	global_position = get_parent().global_position + editor_offset.rotated(get_parent().global_rotation)
	global_rotation = get_parent().global_rotation
	
	velocity = Vector2(power, 0).rotated(global_rotation)
