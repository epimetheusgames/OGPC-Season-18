extends Node2D

var dialog_played: bool = false
var dialog_speed: float = 0
var dialog_played_time: float = 0


func _ready() -> void:
	get_node("TextureRect").size = get_node("RichTextLabel").size*0.9
	get_node("TextureRect").position = get_node("RichTextLabel")
	
func _process(delta:float):
	if(not dialog_played):
		dialog_played_time += delta*60
		if(dialog_played_time>=dialog_speed):
			dialog_played = true

func play_dialog(dialog:String, dialog_speed_inp:int):
	dialog_played = false
	dialog_speed = dialog_speed_inp
