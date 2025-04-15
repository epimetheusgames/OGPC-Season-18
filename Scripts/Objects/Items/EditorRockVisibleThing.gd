@tool
extends Node

@export var rock_sprites: Array[Sprite2D]

func _process(delta: float) -> void:
	for sprite in rock_sprites:
		if sprite.visible: return
	
	(rock_sprites.pick_random() as Sprite2D).visible = true
