extends Node2D

var dialog_played: bool = false
var dialog:String = ""
# In characters per second 
var dialog_speed: float = 100

# In characters per second, this is so theres a lil pause between a period
#(as you might in real human speech)
var dialog_speed_period: float = 1

var dialog_played_time: float = 0

var last_played_letterindex: int = 0
@onready var text_node = get_node("DialogTextLabel")
func _ready() -> void:
	get_node("DialogTextLabel").size = get_node("DialogTextureBG").size*0.9
	get_node("DialogTextLabel").position = get_node("DialogTextureBG").position
	play_dialog("hi im a silly little dialog thingy. doing dialog stuff. look at me isnt that interesting",10)

func _process(delta:float):
	if(not dialog_played):
		if(not int(dialog_played_time/dialog_speed)==dialog.length()-1):
			if(dialog[int(dialog_played_time/dialog_speed)+1]=="."):
				dialog_played_time += delta*60*dialog_speed_period
			else:
				dialog_played_time += delta*60*dialog_speed
		else:
			dialog_played_time += delta*60*dialog_speed
			
		if(int(dialog_played_time/dialog_speed)!=last_played_letterindex):
			if(int(dialog_played_time/dialog_speed)==dialog.length()):
				text_node.text += dialog[dialog.length()-1]
			else:
				text_node.text += dialog[int(dialog_played_time/dialog_speed)]
		if(dialog_played_time>=dialog_speed*dialog.length()-1):
			dialog_played = true
		last_played_letterindex = int(dialog_played_time/dialog_speed)
func play_dialog(dialog_input:String, dialog_speed_inp:int):
	dialog_played = false
	dialog = dialog_input
	dialog_speed = dialog_speed_inp
	
