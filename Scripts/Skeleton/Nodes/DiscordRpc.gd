class_name DiscordRPCSkeleton
extends Node

func _ready() -> void:
    DiscordRPC.app_id = 1355019921884577842
    DiscordRPC.details = "Epimetheus Games' submission for Season 18 of OGPC"
    DiscordRPC.state = "In the main menu"
    DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
    DiscordRPC.refresh()

func _process(_delta: float) -> void:
    DiscordRPC.run_callbacks()