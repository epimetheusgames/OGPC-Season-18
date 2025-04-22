# Global autoload for variables that need to be accessed by all nodes.
# Avoid setting values in here if you aren't a skeleton node.
# See https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html 
extends Node2D

## Root node of the whole game
var root_node: Node

## Brightness percentage, in decimal form 
var  brightness_decimal: int = 1
## Save load framework node, constant.
var save_load_framework: SaveLoadFramework

## Node that contains skeleton nodes like SaveLoadFramework, GodotSteamAbstraction,
## MissionSystem, and GameTimeSystem.
var game_skeleton_node: Node

## Main menu UI root node.
var ui_root_node: Control

## Game container root node, constant.
var game_root_node: Node
var KeyactionHandler: Node2D

## Path to the current mission scene.
var current_scene_path: String

## Current loaded game slot if the game is running.
var current_game_slot: int

## If we are currently in a multiplayer game or lobby.
var is_multiplayer: bool

## Boids calculator node, constant.
var boids_calculator_node: BoidsCalculator

## The current diver in the mission scene.
## NEVER use this in a multiplayer context, it will be overriden everytime a 
## new player joins. Instead if you are an entity use closest_player.
var player: Diver

## The current submarine in the mission scene.
var submarine : Entity
var dialog_core: TextureRect = null

## Handles networking, constant.
var godot_steam_abstraction: GodotSteamAbstraction

## Current game save resource, modify when saving things.
var current_game_save: GameSave

## Mission system node, constant.
var mission_system: MissionSystem

## Time node, constant.
var game_time_system: GameTimeSystem

## Whether to print debug in the ingame console and in the terminal.
var verbose_debug: bool

## Mostly depracated but changes some settings to make graphics worse and have
## better performance on lower end devices.
var super_efficient: bool

## Whether dialog is being played right now.
var dialog_active: bool = false

## Idk what this is.
var dialog_played: bool = true

## The node of the current mission. If you make this typed you'll break the game. (brake)
var current_mission_node = null

## The resource this mission uses.
var current_mission: Mission

## The currently active debug console.
var chat: MinimalChat

## Text printed to debug console, so it can be synced up.
var chat_text: String

## Current research station node.
var research_station: ResearchStation

## Ingame canvas modulate used for lighting (time of day)
var canvas_modulate: CanvasModulate

## Canvas modulate used to change the brightness of the game depending on whats set in settings
var brightness_modulate: CanvasModulate
## The light that acts as the sun.
var sun: DirectionalLight2D

var death_menu: DeathScreen
var success_menu: MissionSuccessScreen
var pause_menu: PauseMenu

## Values as shown in Collision Bitmasks section of GDSCRIPTRULESL.md
var bitmask_conversion = {
	"General Collision": 1,
	"Player Hurtbox / Enemy Attackbox": 2,
	"Light": 4,
	"Movement": 8,
	"Wall Layer 2": 16,
	"Player Attackbox / Enemy Hurtbox": 32,
	"Interaction": 64,
}

var player_array: Array[Diver]

var rng := RandomNumberGenerator.new()

## Overrides a default function which is great, prints to the ingame chat 
## if verbose debug is on, and also prints to the console.
func print_debug(message: String):
	if !verbose_debug:
		return
	
	message = message.replace("DEBUG: ", "")
	print("DEBUG: " + message)
	if chat:
		chat.push_debug(message)
		chat_text = chat.text.text
	else:
		chat_text += "\nDEBUG: " + message

## Prints an error the the console allways, but only to the ingame console
## if verbsoe debug is on.
func print_error(message: String, error_type := Util.ErrorType.ERROR):
	if chat is ChatPanel:
		chat.typing_command_override = true
	
	var chat_pretext: String = ""
	var sender: String = ""
	var sender_color: String = ""
	if error_type == Util.ErrorType.WARNING:
		chat_pretext = "WARNING: "
		sender = "SystemWarning"
		sender_color = "yellow"
	elif error_type == Util.ErrorType.ERROR:
		chat_pretext = "ERROR: "
		sender = "SystemError"
		sender_color = "red"
	elif error_type == Util.ErrorType.CRITICAL_ERROR:
		chat_pretext = "CRITICAL ERROR: "
		sender = "SystemFatal"
		sender_color = "red"
	
	print(chat_pretext + message)

	if !verbose_debug:
		return
	
	if chat:
		chat.push_chat(sender, message, sender_color, "antiquewhite ")
		chat_text = chat.text.text
	else:
		chat_text += "\nERROR: " + message

## Gets the slot encryption password.
func get_slot_password(slot_num: int) -> String:
	var result_string = ""
	
	for i in range(5):
		var semi_random_number := slot_num * 1000 + i * 10000
		semi_random_number *= 56728936588
		semi_random_number ^= 54687279475
		semi_random_number /= 368246
		result_string += str(semi_random_number)
	
	return result_string

## If multiplayer check if this instance is the lobby owner.
func is_multiplayer_host() -> bool:
	if godot_steam_abstraction:
		return godot_steam_abstraction.is_lobby_owner
	return false

## Set game brightness throuhg brightness modulate, based on percentage from 0 to 100
func set_brightness(percentage):
	brightness_decimal = percentage/100
	brightness_modulate.color.r = brightness_decimal
	brightness_modulate.color.g = brightness_decimal
	brightness_modulate.color.b = brightness_decimal
