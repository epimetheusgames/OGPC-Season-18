## Base class for all NPCs (including enemies!)

class_name NPC
extends Entity

# Dialog will be undertale-style rectangle thingies with text, and funny beeping sounds 

# Read format of dialog.json to understand what this is used for 
var npc_name = "test_dialog"

# Dialog speed in characters per second 
@export var dialog_speed: int

# dialog and responses to pass to textposset
var dialog_thingy

#the current array path to the next dialog
var current_location:String = 'dialog["dialog"]['+npc_name+']'
#the current array path to the next set of responses
var current_location_responses:String = 'dialog["dialog"]['+npc_name+']'

# Dialog beep sound thingy 
@export_file("*.wav") var talking_sound

var conversation_index := 0
var sentence_index := 0

var dialog: Dictionary
var dialog_json: JSON

func _option_chosen():
	current_location+="["+String(Global.dialog_core.response)+"][0]"
	current_location_responses+="["+String(Global.dialog_core.response)+"][1]"
	Global.dialog_core.play_dialog(Global.eval('var dialog;var dialog_json = JSON.new();dialog_json.parse(FileAccess.open("res://Scenes/Resource/Level/Dialog.json", FileAccess.READ).get_as_text());dialog = dialog_json.data;return '+current_location+';'),dialog_speed,Global.eval('var dialog;var dialog_json = JSON.new();dialog_json.parse(FileAccess.open("res://Scenes/Resource/Level/Dialog.json", FileAccess.READ).get_as_text());dialog = dialog_json.data;return '+current_location_responses+';'))
func _get_dialogue():
	dialog_json.parse(FileAccess.open("res://Scenes/Resource/Level/Dialog.json", FileAccess.READ).get_as_text())
	dialog = dialog_json.data

func _ready() -> void:
	get_node("AudioHandler/TalkSound").stream = AudioStreamWAV.new()
	Global.dialog_core.dialog_option_chosen.connect(_option_chosen)

func die() -> void:
	pass

func trigger_talking() -> void:
	#index 0 is the dialogue, [0][1] [0][2] [0][3] and [0][4] are responses
	Global.dialog_core.play_dialog(dialog["dialog"][npc_name][0],dialog_speed,dialog["dialog"][npc_name][0])

	
