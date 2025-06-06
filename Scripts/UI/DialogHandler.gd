# code made by sequoia
class_name DialogCore
extends TextureRect

signal dialog_option_chosen

var dialog_played: bool = false
var dialog:String = ""
# In characters per second 
var dialog_speed: float = 10

var response_buttons:Array[ColorRect] = []
var response:int = -1

# In characters per second, this is so theres a lil pause between a period
#(as you might in real human speech)
var dialog_speed_period: float = 1
var characters_played: float = 0
var last_played_letterindex: int = 0

var dialog_sfx_node: AudioStreamPlayer

var shit
var dumb
@export_node_path("ColorRect") var response_button_one
@export_node_path("ColorRect") var response_button_two
@export_node_path("ColorRect") var response_button_three
@export_node_path("ColorRect") var response_button_four
@export var text_node:RichTextLabel

func _ready() -> void:
	response_buttons.append(get_node(response_button_one))
	response_buttons.append(get_node(response_button_two))
	response_buttons.append(get_node(response_button_three))
	response_buttons.append(get_node(response_button_four))
	response_buttons[0].button_down.connect(response_option_one)
	response_buttons[1].button_down.connect(response_option_two)
	response_buttons[2].button_down.connect(response_option_three)
	response_buttons[3].button_down.connect(response_option_four)	
	get_node("VBoxContainer").get_node("DialogTextLabel").size = self.size*0.9
	get_node("VBoxContainer").get_node("DialogTextLabel").position = self.position
	shit = get_parent().name
	print(shit)
	shit = get_parent().name=="GameUIOverlay"
	print(get_parent().name=="GameUIOverlay")
	if(!(get_parent().name == "GameUIOverlay")):
		Global.dialog_core = self

func _process(delta:float)->void:
	Global.dialog_played = !Global.dialog_active
	if(not dialog_played && dialog.length()!=0):
		
		if(not int(characters_played)>=dialog.length() && dialog[int(characters_played)-1]=="."):
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
func get_response()->int:
	return response
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
func play_dialog(dialog_input:String, dialog_speed_inp:int, options):
	dumb = dialog_input
	for i in range(response_buttons.size()):
		response_buttons[i].disabled = true
		response_buttons[i].visible = false
	if(options!=null):
		for i in range(options.size()):
			response_buttons[i].disabled = false
			response_buttons[i].visible = true
			response_buttons[i].text = options[i][0]
	dialog_played = false
	dialog = dialog_input
	dialog_speed = dialog_speed_inp
	text_node.text = ""
	
