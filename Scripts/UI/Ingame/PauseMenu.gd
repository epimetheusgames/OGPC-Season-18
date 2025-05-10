class_name PauseMenu
extends Control


@export var ingame_ui: Control
@export var vignette_shader: ColorRect

func _ready() -> void:
	Global.pause_menu = self
	
	var save := Global.save_load_framework._load_global_config()
	$SoundMenu/MasterVolumeSlider.value = save.master_volume
	_on_master_volume_slider_value_changed(save.master_volume)
	$SoundMenu/MusicVolumeSlider.value = save.music_volume
	_on_music_volume_slider_value_changed(save.music_volume)
	$SoundMenu/SFXVolumeSlider.value = save.sfx_volume
	_on_sfx_volume_slider_value_changed(save.sfx_volume)

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
	$SoundMenu.visible = true
	$SettingsButton.visible = false
	$ResumeButton.visible = false
	$QuitButton.visible = false

func _on_exit_button_button_up() -> void:
	get_tree().paused = false
	Global.save_load_framework.save_state()
	Global.save_load_framework.exit_to_menu()

func _on_no_button_button_up() -> void:
	$AreYouSurePanel.visible = false

func _on_sound_menu_back_button_button_up() -> void:
	$SoundMenu.visible = false
	$SettingsButton.visible = true
	$ResumeButton.visible = true
	$QuitButton.visible = true

func update_global_save() -> void:
	var save := GlobalSave.new()
	save.master_volume = $SoundMenu/MasterVolumeSlider.value
	save.music_volume = $SoundMenu/MusicVolumeSlider.value
	save.sfx_volume = $SoundMenu/SFXVolumeSlider.value
	Global.save_load_framework._save_global_config(save)

func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), value / 100.0)
	update_global_save()

func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), value / 100.0)
	update_global_save()

func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value / 100.0)
	update_global_save()
