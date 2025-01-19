class_name MissionUIBox
extends Control


@export var associated_mission: Mission
@export var connects_to: Array[MissionUIBox]

func _ready() -> void:
	if !self in Global.mission_system.mission_tree.get_available_missions():
		modulate = Color(0.5, 1, 0.533)

func _process(delta: float) -> void:
	if !Global.is_multiplayer_host() && Global.is_multiplayer:
		$MissionButton.disabled = true
	else:
		$MissionButton.disabled = false
	
	if !associated_mission:
		print("ERROR: Mission at path " + str(get_path()) + " has no associated mission resource.")
		return
	
	$Panel/Title.text = associated_mission.title
	$Panel/Description.text = associated_mission.description

func _on_mission_button_button_up() -> void:
	if Global.verbose_debug:
		print("DEBUG: Starting game on mission " + associated_mission.title)
	
	Global.save_load_framework.exit_to_menu()
	Global.godot_steam_abstraction.run_remote_function(Global.save_load_framework, "exit_to_menu", [])
	Global.save_load_framework.start_game(0, associated_mission) 
	Global.godot_steam_abstraction.run_remote_function(
		Global.save_load_framework, "start_game_remote", 
		[0, Global.mission_system.default_mission_tree.get_mission_by_resource(associated_mission)]
	)
