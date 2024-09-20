## Base class for all NPCs (including enemies!)

class_name NPC
extends Entity

# Dialog will be undertale-style rectangle thingies with text, and funny beeping sounds 

# Dialog speed in characters per second 
@export var dialog_speed: int

# Dialog beep sound thingy 
@export_file("*.wav") var talking_sound

# Name of our conversational object.
@export var conv_obj_name := ""

var conversation_index := 0
var sentence_index := 0

var dialog: Dictionary
var dialog_json: JSON

func _get_dialogue():
	dialog_json.parse(FileAccess.open("res://Scenes/Resource/Level/Dialog.json", FileAccess.READ).get_as_text())
	dialog = dialog_json.data

func _ready() -> void:
	get_node("AudioHandler/TalkSound").stream = AudioStreamWAV.new()

func die() -> void:
	pass

func trigger_talking() -> void:
	pass
