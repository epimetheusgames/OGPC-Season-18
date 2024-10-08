# Global autoload for variables that need to be accessed by all nodes.
# Avoid setting values in here if you aren't a skeleton node.
# See https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html 
extends Node

var root_node: Node
var save_load_framework: Node
var game_skeleton_node: Node
var ui_root_node: Control
var game_root_node: Node
var current_scene_path: String
var current_game_slot: int
var is_multiplayer: bool
var dialog_text_node: Node2D
var boids_calculator_node: BoidsCalculator
var godot_steam_abstraction: GodotSteamAbstraction

enum MULTIPLAYER_MODE {
	SINGLEPLAYER,
	LOCAL_NETWORK,
	GD_SYNC,
}

func get_slot_password(slot_num: int) -> String:
	var result_string = ""
	
	for i in range(5):
		var semi_random_number := slot_num * 1000 + i * 10000
		semi_random_number *= 56728936588
		semi_random_number ^= 54687279475
		semi_random_number /= 368246
		result_string += str(semi_random_number)
	
	return result_string

func is_multiplayer_host() -> bool:
	var multiplayer_type := get_multiplayer_type()
	
	if multiplayer_type == MULTIPLAYER_MODE.GD_SYNC && GDSync.is_host():
		return true
	elif multiplayer_type == MULTIPLAYER_MODE.LOCAL_NETWORK && is_multiplayer_authority():
		return true
	
	return false

func get_multiplayer_type() -> MULTIPLAYER_MODE:
	if GDSync.is_active():
		return MULTIPLAYER_MODE.GD_SYNC
	elif is_multiplayer:
		return MULTIPLAYER_MODE.LOCAL_NETWORK
	else:
		return MULTIPLAYER_MODE.SINGLEPLAYER
