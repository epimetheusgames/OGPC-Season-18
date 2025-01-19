class_name PauseMenu
extends Control


@export var ingame_ui: Control
@export var vignette_shader: ColorRect

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		vignette_shader.material.set_shader_parameter("vignette_strength", 1.5)
		ingame_ui.visible = false
		get_tree().paused = true
		visible = true

func _on_quit_button_button_up() -> void:
	get_tree().paused = false
	Global.save_load_framework.exit_to_menu()

func _on_resume_button_button_up() -> void:
	get_tree().paused = false
	ingame_ui.visible = true
	visible = false
	vignette_shader.material.set_shader_parameter("vignette_strength", 1)

func _on_settings_button_button_up() -> void:
	# Doesn't do anything yet, but it will open the settings menu.
	pass
