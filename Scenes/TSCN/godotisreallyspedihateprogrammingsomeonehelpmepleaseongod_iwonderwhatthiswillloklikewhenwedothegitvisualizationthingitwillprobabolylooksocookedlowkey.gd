extends "res://Scripts/UI/SettingsMenu.gd"

func _process(delta:float) -> void:
	## Make sure that the export vars and get_nodes have all loaded
	if(BrightnessSlider!=null&&SoundMenuBackButton!=null):
		SoundButton.pressed.connect(func(): SoundSubMenu.visible = true)
		SoundMenuBackButton.pressed.connect(func(): SoundSubMenu.visible = false)
		master_bus_db = AudioServer.get_bus_volume_db(0)
		SoundSlider.value_changed.connect(_master_volume_changed)
		BrightnessSlider.value_changed.connect(func(): Global.set_brightness(BrightnessSlider.value))
	
func _back_button_pressed() -> void:
	self.visible = false
	$"../MainMenu".visible = true
