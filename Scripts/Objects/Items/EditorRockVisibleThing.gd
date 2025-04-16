@tool
extends Node

@export var rock_sprites: Array[Sprite2D]
@export var kIlL_iT_aLl := false

func _ready() -> void:
	kIlL_iT_aLl = false

func _process(delta: float) -> void:
	if kIlL_iT_aLl:
		return
	
	for sprite in rock_sprites:
		if sprite.visible: return
	
	(rock_sprites.pick_random() as Sprite2D).visible = true
