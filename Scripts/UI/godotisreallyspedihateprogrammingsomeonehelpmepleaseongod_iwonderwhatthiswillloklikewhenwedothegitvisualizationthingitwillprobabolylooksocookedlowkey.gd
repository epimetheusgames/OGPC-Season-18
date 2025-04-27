extends "res://Scripts/UI/SettingsMenu.gd"

func _process(delta:float) -> void:
	## Make sure that the export vars and get_nodes have all loaded
	if(!HasCodeRan&&BrightnessSlider!=null&&SoundMenuBackButton!=null):
		BackButton.pressed.connect(func(): self.visible = false)
		SoundButton.pressed.connect(_open_sound_button)
		SoundMenuBackButton.pressed.connect(_close_sound_button)
		master_bus_db = AudioServer.get_bus_volume_db(0)
		HasCodeRan = true
	
func _back_button_pressed() -> void:
	self.visible = false
	$"../MainMenu".visible = true
