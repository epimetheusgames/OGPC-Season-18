class_name NPC
extends Entity

# Dialog will be undertale-style rectangle thingies with text, and funny beeping sounds 

# Dialog speed in characters per second 
@export var dialog_speed: int

# Dialog beep sound thingy 
@export var dialog_sound = "yap_bad.wav"

var dialogue: Array
var dialogue_json: JSON
func _get_dialogue():
	# My bad guys just got a little silly
	dialogue_json.parse(FileAccess.open("res://Scenes/Resource/dialog.json", FileAccess.READ).get_as_text())
	dialogue = dialogue_json.data
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("AudioHandler/TalkSound").stream = AudioStreamWAV.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func die() -> void:
	
func yap() -> void:
