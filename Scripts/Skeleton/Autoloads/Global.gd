# Global autoload for variables that need to be accessed by all nodes.
# Avoid setting values in here if you aren't a skeleton node.
# See https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html 
extends Node

var root_node: Node
var save_load_framework: SaveLoadFramework
var game_skeleton_node: Node
var ui_root_node: Control
var game_root_node: Node
var KeyactionHandler: Node2D
var current_scene_path: String
var current_game_slot: int
var is_multiplayer: bool
var dialog_text_node: Node2D
var boids_calculator_node: BoidsCalculator
var player: Diver
var submarine : Entity
var dialog_core: Node2D
var godot_steam_abstraction: GodotSteamAbstraction
var current_game_save: GameSave
var mission_system: MissionSystem
var verbose_debug: bool
var super_efficient: bool

# Values as shown in Collision Bitmasks section of GDSCRIPTRULESL.md
var bitmask_conversion = {
	"General Collision": 1,
	"Player Hurtbox / Enemy Attackbox": 2,
	"Light": 4,
	"Movement": 8,
	"Wall Layer 2": 16,
	"Player Attackbox / Enemy Hurtbox": 32,
	"Interaction": 64,
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
	return godot_steam_abstraction.is_lobby_owner

# Run code from a string
func eval(input: String):
	var script_holder = RefCounted.new()
	var script = GDScript.new()
	script.set_source_code("func eval():" + input)
	script.reload()
	script_holder.set_script(script)
	return script_holder.eval()

# Yes this will always be there.
func get_world_2d():
	return KeyactionHandler.get_world_2d()
