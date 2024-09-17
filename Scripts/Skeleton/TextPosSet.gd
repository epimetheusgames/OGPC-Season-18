extends Node2D

var dialog_played: bool = false
var dialog:String = ""
# In characters per second 
var dialog_speed: float = 0

var dialog_played_time: float = 0

@onready var text_node = get_node("TextureRect")
func _ready() -> void:
	get_node("TextureRect").size = get_node("RichTextLabel").size*0.9
	get_node("TextureRect").position = get_node("RichTextLabel")
	play_dialog("hi im a silly little dialog thingy doing dialog stuff look at me isnt that interesting",10)
func _process(delta:float):
	if(not dialog_played):
		dialog_played_time += delta*60
		text_node.text += dialog[int(dialog_played_time/dialog_speed)]
		if(dialog_played_time>=dialog_speed):
			dialog_played = true

func play_dialog(dialog_input:String, dialog_speed_inp:int):
	dialog_played = false
	dialog = dialog_input
	dialog_speed = dialog_speed_inp
