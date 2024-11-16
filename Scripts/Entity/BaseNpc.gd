## Base class for all NPCs (including enemies!)

class_name NPC
extends Entity
@export var dialog_hitbox_size:int
@export_node_path("Area2D") var dialog_area
# Dialog will be undertale-style rectangle thingies with text, and funny beeping sounds 

# Make dialog name in dialog.json this name
@export var npc_name:String

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

func _process(delta: float) -> void:
	_npc_process(delta)

func _npc_process(delta: float) -> void:
	_entity_process(delta)

func touching_bodies() -> bool:
	var bodies = dialog_area.get_overlapping_bodies()
	#omg functional programming moment (lambdas)
	bodies = bodies.filter(func(node): return node is CharacterBody2D)
	print("chat are the bodies finna touching the npc")
	print(bodies)
	return bodies.length>0
func _option_chosen():
	current_location+="["+String(Global.dialog_core.response)+"][0]"
	current_location_responses+="["+String(Global.dialog_core.response)+"][1]"
	Global.dialog_core.play_dialog(Global.eval('var dialog;var dialog_json = JSON.new();dialog_json.parse(FileAccess.open("res://Scenes/Resource/Level/Dialog.json", FileAccess.READ).get_as_text());dialog = dialog_json.data;return '+current_location+';'),dialog_speed,Global.eval('var dialog;var dialog_json = JSON.new();dialog_json.parse(FileAccess.open("res://Scenes/Resource/Level/Dialog.json", FileAccess.READ).get_as_text());dialog = dialog_json.data;return '+current_location_responses+';'))
func _get_dialogue():
	dialog_json.parse(FileAccess.open("res://Scenes/Resource/Level/Dialog.json", FileAccess.READ).get_as_text())
	dialog = dialog_json.data

func _ready() -> void:
	get_node("AudioHandler/TalkSound").stream = AudioStreamWAV.new()
	Global.dialog_text_node.dialog_option_chosen.connect(_option_chosen)
	get_node("Hitbox").ready.connect(do_that_thingy)
func do_that_thingy() -> void:
	#hitbox for interacting with npc, you shouldnt need to be touching them to talk with them
	var dialog_area = get_node("DialogHitbox")
	var dialog_hitbox = CollisionShape2D.new()
	dialog_hitbox.shape = RectangleShape2D.new()
	dialog_hitbox.shape.size = get_node("Hitbox").size + Vector2(dialog_hitbox_size,dialog_hitbox_size)
	dialog_area.add_child(dialog_hitbox)
	Global.KeyactionHandler.interact.connect(try_trigger_talking)
func die() -> void:
	#play some skibidi death animation or something
	
	self.queue_free()
func try_trigger_talking() -> void:
	if(touching_bodies()):
		trigger_talking()
func trigger_talking() -> void:
	#index 0 is the dialogue, [0][1] [0][2] [0][3] and [0][4] are responses
	Global.dialog_core.play_dialog(dialog["dialog"][npc_name][0],dialog_speed,dialog["dialog"][npc_name][0])

	
