extends Node2D

signal dialog_option_chosen

var dialog_played: bool = false
var dialog:String = ""
# In characters per second 
var dialog_speed: float = 10

var response_buttons:Array[Button] = []
var response:int = -1

# In characters per second, this is so theres a lil pause between a period
#(as you might in real human speech)
var dialog_speed_period: float = 1
var characters_played: float = 0
var last_played_letterindex: int = 0

var dialog_sfx_node: AudioStreamPlayer

@onready var text_node = get_node("DialogTextLabel")

func _ready() -> void:
	response_buttons[0] = get_node("ResponseButtonOne")
	response_buttons[1] = get_node("ResponseButtonTwo")
	response_buttons[2] = get_node("ResponseButtonThree")
	response_buttons[3] = get_node("ResponseButtonFour")
	response_buttons[0].button_down.connect(response_option_one)
	response_buttons[1].button_down.connect(response_option_two)
	response_buttons[2].button_down.connect(response_option_three)
	response_buttons[3].button_down.connect(response_option_four)	
	get_node("DialogTextLabel").size = get_node("DialogTextureBG").size*0.9
	get_node("DialogTextLabel").position = get_node("DialogTextureBG").position

func _process(delta:float)->void:
	if(not dialog_played):
		if(not int(characters_played)==dialog.length() && dialog[int(characters_played)]=="."):
			characters_played += (dialog_speed_period / 60) * delta*60
		else:
			characters_played += (dialog_speed / 60) * delta*60
		
		if(characters_played >= dialog.length()):
			dialog_played = true
		elif int(characters_played) != last_played_letterindex:
			text_node.text += dialog[int(characters_played)]
			
			# Play beep sfx
			if dialog_sfx_node:
				dialog_sfx_node.play()
		
		last_played_letterindex = int(characters_played)
	
func response_option_one()->void:
	response = 0
	dialog_played = true
	dialog_option_chosen.emit()
func response_option_two()->void:
	response = 1
	dialog_played = true
	dialog_option_chosen.emit()
func response_option_three()->void:
	response = 2
	dialog_played = true
	dialog_option_chosen.emit()	
func response_option_four()->void:
	response = 3
	dialog_played = true
	dialog_option_chosen.emit()
func play_dialog(dialog_input:String, dialog_speed_inp:int, options:Array):
	for i in range(options.size()):
		response_buttons[i].disabled = true
		response_buttons[i].visible = false
	for i in range(options.size()):
		response_buttons[i].disabled = false
		response_buttons[i].visible = true
		response_buttons[i].text = options[i]
	dialog_played = false
	dialog = dialog_input
	dialog_speed = dialog_speed_inp
	text_node.text += dialog[0]
	
