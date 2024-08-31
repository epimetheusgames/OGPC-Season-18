extends Node
signal do_lerp
@onready var ui_gen = get_parent().get_node("ui_gen")
var lerp_counter = 0
var current_val:Vector2

var lerp_time = 0
#start and end of the lerp
var places = [Vector2(0,0),Vector2(0,0)]

var lerping = false
func StartLerp() -> void:
	lerping = true
	
func _ready() -> void:
	do_lerp.connect(StartLerp)
	
func _process(delta: float) -> void:
	lerp_counter += delta * lerp_time
	if(lerping):
		current_val = places[0].lerp(places[1],lerp_counter)
		if(current_val==places[1]):
			lerping = false
	else:
		lerp_time = 0
		lerp_counter = 0
