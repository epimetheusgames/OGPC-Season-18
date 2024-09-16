extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("TextureRect").size = get_node("RichTextLabel").size*0.9
	get_node("TextureRect").position = get_node("RichTextLabel")
func play_dialog(dialog:string):
	
