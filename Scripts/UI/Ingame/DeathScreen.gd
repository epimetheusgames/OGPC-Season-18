class_name DeathScreen
extends Control


@export var ingame_ui: Control
@export var vignette_shader: ColorRect

func _process(delta: float) -> void:
	if Global.player && Global.player.get_diver_health() <= 0:
		vignette_shader.material.set_shader_parameter("vignette_strength", 1.5)
		ingame_ui.visible = false
		get_tree().paused = true
		visible = true

func _on_restart_button_button_up() -> void:
	get_tree().paused = false
	Global.mission_system.restart_mission()

func _on_quit_button_button_up() -> void:
	get_tree().paused = false
	Global.save_load_framework.exit_to_menu()
