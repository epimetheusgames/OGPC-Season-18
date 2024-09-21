extends Node2D

var dialog_played: bool = false
var dialog:String = ""
# In characters per second 
var dialog_speed: float = 10

# In characters per second, this is so theres a lil pause between a period
#(as you might in real human speech)
var dialog_speed_period: float = 1

var characters_played: float = 0

var last_played_letterindex: int = 0

@onready var text_node = get_node("DialogTextLabel")
func _ready() -> void:
	get_node("DialogTextLabel").size = get_node("DialogTextureBG").size*0.9
	get_node("DialogTextLabel").position = get_node("DialogTextureBG").position
	play_dialog("hi im a silly little dialog thingy. doing dialog stuff. look at me isnt that interesting",10)

func _process(delta:float):
	if(not dialog_played):
		if(not int(characters_played)==dialog.length() && dialog[int(characters_played)]=="."):
			characters_played += (dialog_speed_period / 60) * delta*60
		else:
			characters_played += (dialog_speed / 60) * delta*60
		
		if(characters_played >= dialog.length()):
			dialog_played = true
		elif int(characters_played) != last_played_letterindex:
			text_node.text += dialog[int(characters_played)]
		
		last_played_letterindex = int(characters_played)
	
func play_dialog(dialog_input:String, dialog_speed_inp:int):
	dialog_played = false
	dialog = dialog_input
	dialog_speed = dialog_speed_inp
	text_node.text += dialog[0]
	
