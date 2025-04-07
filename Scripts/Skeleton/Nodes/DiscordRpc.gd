class_name DiscordRPCSkeleton
extends Node

func _ready() -> void:
	DiscordRPC.app_id = 1355019921884577842
	DiscordRPC.details = "Epimetheus Games' submission for Season 18 of OGPC"
	DiscordRPC.state = "In the main menu"
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	DiscordRPC.refresh()
	
	Global.save_load_framework.game_started.connect(_start_game)
	Global.save_load_framework.on_exit_to_menu.connect(_exit_to_menu)

func _exit_to_menu() -> void:
	DiscordRPC.state = "In the main menu"
	DiscordRPC.refresh()

func _start_game() -> void: 
	DiscordRPC.state = "In the game"
	DiscordRPC.refresh()

func _process(_delta: float) -> void:
	DiscordRPC.run_callbacks()
