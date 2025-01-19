class_name MissionSuccessScreen
extends Control


@export var ingame_ui: Control
@export var vignette_shader: ColorRect

func _process(delta: float) -> void:
	if Global.current_mission && Global.current_mission.success_state_checker.check_success():
		if Global.current_mission in Global.mission_system.mission_tree.get_available_missions():
			Global.mission_system.complete_mission(Global.current_mission)
		vignette_shader.material.set_shader_parameter("vignette_strength", 1.5)
		ingame_ui.visible = false
		get_tree().paused = true
		visible = true

func _on_return_to_station_button_up() -> void:
	get_tree().paused = false
	Global.save_load_framework.exit_to_menu()
	Global.save_load_framework.start_game(Global.current_game_slot)

func _on_quit_button_button_up() -> void:
	get_tree().paused = false
	Global.save_load_framework.exit_to_menu()
