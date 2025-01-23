# code owned by sequoia
## Base class for all NPCs (including enemies!)

class_name NPC
extends Entity
@export var dialog_hitbox_size:int
@export_node_path("Area2D") var dialog_area
# Dialog will be undertale-style rectangle thingies with text, and funny beeping sounds 

var doo_doo
var mission_dialog_core_set = false
var ready_run_count = 0


# Make dialog name in dialog.json this name
@export var npc_name:String


# Dialog speed in characters per second 
@export var dialog_speed: int

# image the npc will appear as
@export var npc_texture: CompressedTexture2D

# controls whether or not the _process will run
@export var has_dialog: bool
# dialog and responses to pass to textposset
var dialog_thingy

#the current array path to the next dialog text
@onready var current_location:String = 'dialog["dialog"]["'+npc_name+'"][1]'
#the current array path to the next set of responses
@onready var current_location_responses:String = 'dialog["dialog"]["'+npc_name+'"][1]'
#the current array path to the next response-text pair
@onready var current_location_text:String = 'dialog["dialog"]["'+npc_name+'"][1]'

# Dialog beep sound thingy 
@export_file("*.wav") var talking_sound
var shat
var conversation_index := 0
var sentence_index := 0

var dialog: Dictionary
var dialog_json: JSON

func touching_bodies() -> bool:
	var bodies = get_node(dialog_area).get_overlapping_bodies()
	#omg functional programming moment (lambdas)
	bodies = bodies.filter(func(node): return node is CharacterBody2D)
	bodies = bodies.filter(func(node): return !(node.name == "Submarine") && !(node.name == self.name))
	print("chat are the bodies finna touching the npc")
	print(bodies)
  
	return bodies.size()>0
func _option_chosen():
	current_location_text+="["+str(Global.dialog_core.response)+"][1][0]"
	current_location += "[" + str(Global.dialog_core.response)+"][1]"
	current_location_responses+= "["+str(Global.dialog_core.response)+"][1][1]"
	shat = Global.eval('var dialog;var dialog_json = JSON.new();dialog_json.parse(FileAccess.open("res://Scenes/Resource/Level/Dialog.json", FileAccess.READ).get_as_text());dialog = dialog_json.data;if(' + current_location + '.size() > 1): return '+current_location_responses+';if(' + current_location + '.size() == 0): return [null];')
	print(shat)
	Global.dialog_core.play_dialog(Global.eval('var dialog;var dialog_json = JSON.new();dialog_json.parse(FileAccess.open("res://Scenes/Resource/Level/Dialog.json", FileAccess.READ).get_as_text());dialog = dialog_json.data;return '+current_location_text+';'),dialog_speed,Global.eval('var dialog;var dialog_json = JSON.new();dialog_json.parse(FileAccess.open("res://Scenes/Resource/Level/Dialog.json", FileAccess.READ).get_as_text());dialog = dialog_json.data;if(' + current_location + '.size() > 1): return '+current_location_responses+';if(' + current_location + '.size() == 0): return [null];'))
func _get_dialog():
	dialog_json.parse(FileAccess.open("res://Scenes/Resource/Level/Dialog.json", FileAccess.READ).get_as_text())
	dialog = dialog_json.data

func _ready() -> void:
	ready_run_count += 1
	if(has_dialog):
		call_deferred("deferred_ready")
	else:
		set_process(false)

func deferred_ready():
	set_process(true)
	if(ready_run_count>0):
		get_node("Texture").texture = npc_texture
		dialog_json = JSON.new()
		_get_dialog()
		get_node("AudioHandler/TalkSound").stream = AudioStreamWAV.new()
		if(Global.dialog_core!=null):
			Global.dialog_core.dialog_option_chosen.connect(_option_chosen)
			mission_dialog_core_set = true
		#doo_doo = 
		if(get_node("Hitbox").is_node_ready()):
			do_that_thingy()
		get_node("Hitbox").ready.connect(do_that_thingy)
   
func do_that_thingy() -> void:
	if(has_dialog) && Global.KeyactionHandler:
		Global.KeyactionHandler.interact.connect(try_trigger_talking)
func die() -> void:
	#play some skibidi death animation or something
	
	self.queue_free()
func try_trigger_talking() -> void:
	if(touching_bodies()):
		trigger_talking()
func trigger_talking() -> void:
	doo_doo = Global.dialog_active
	if(!Global.dialog_active):
		Global.dialog_active = true
		#index [0] is the dialogue, [1][0] [1][1] [1][2] and  etc are responses
		Global.dialog_core.play_dialog(dialog["dialog"][npc_name][0],dialog_speed,dialog["dialog"][npc_name][1])
	else:
		Global.dialog_active = false
func _process(delta) -> void:
	super(delta)
	if(!has_dialog):
		self.process_mode = Node.PROCESS_MODE_DISABLED
		return
	Global.dialog_core.visible = Global.dialog_active
	# should only run a few frames before the dialog ui is loaded into the mission
	if(!mission_dialog_core_set):
		deferred_ready()
	if Global.dialog_core:
		Global.dialog_core.visible = Global.dialog_active
	
