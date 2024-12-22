class_name DiverFlashlight

extends Node2D

@onready var diver: Diver = get_parent()

@onready var light_texture: PointLight2D = $"Light"

func _process(_delta: float) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var head_pos: Vector2 = diver.diver_animation.get_head_position()
	
	set_light_position(head_pos)
	set_light_rotation(head_pos.angle_to_point(mouse_pos))

func set_light_position(pos: Vector2) -> void:
	light_texture.global_position = pos

func set_light_rotation(rot: float) -> void:
	light_texture.global_rotation = rot + PI / 2.0
