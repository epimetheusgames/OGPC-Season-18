class_name PauseMenu
extends Control


@export var ingame_ui: Control
@export var vignette_shader: ColorRect

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		if !visible:
			if vignette_shader:
				vignette_shader.material.set_shader_parameter("vignette_strength", 1.5)
			ingame_ui.visible = false
			get_parent().visible = true
			get_tree().paused = true
			visible = true
		else:
			_on_resume_button_button_up()

func _on_quit_button_button_up() -> void:
	$AreYouSurePanel.visible = true

func _on_resume_button_button_up() -> void:
	get_tree().paused = false
	ingame_ui.visible = true
	visible = false
	if vignette_shader:
		vignette_shader.material.set_shader_parameter("vignette_strength", 1)
	
func _settings_open():
	get_parent().get_node("Settings").visible = true

func _on_exit_button_button_up() -> void:
	get_tree().paused = false
	Global.save_load_framework.exit_to_menu()

func _on_no_button_button_up() -> void:
	$AreYouSurePanel.visible = false
