extends "res://Scripts/UI/SettingsMenu.gd"

func _ready() -> void:
	soundButton.pressed.connect(func(): soundSubMenu.visible = true)
	soundMenuBackButton.pressed.connect(func(): soundSubMenu.visible = false)
	master_bus_db = AudioServer.get_bus_volume_db(0)
	soundSlider.value_changed.connect(_master_volume_changed)
	brightnessSlider.value_changed.connect(func(): Global.set_brightness(brightnessSlider.value))
	
func _back_button_pressed() -> void:
	self.visible = false
	$"../MainMenu".visible = true
