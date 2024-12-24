class_name MultiplayerSpecialSyncComponent
extends BaseComponent

@export var var_names: Array[String]
@export var on: Node

func _process(delta: float) -> void:
	if !Global.is_multiplayer:
		return
	
	if !on:
		print("ERROR: MultiplayerSpecialSyncComponent at path " + str(get_path()) + " doesn't have a node to set to it can't sync variables.")
		return
	
	if !Global.godot_steam_abstraction.is_lobby_owner:
		return
	
	for item in var_names:
		Global.godot_steam_abstraction.sync_var(on, item)
