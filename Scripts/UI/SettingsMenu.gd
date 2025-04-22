extends Control
var master_bus_db
@onready var BackButton = get_node("BackButton")
@onready var SoundButton = get_node("HBoxContainer/VBoxContainer/SoundButton")
@onready var SoundSubMenu = get_node("SoundSubMenu")
@onready var SoundMenuBackButton = get_node("SoundSubMenu/BackButton")
@export var BrightnessSlider: HSlider
@export var PerformanceButton: Button
@export var SoundSlider: HSlider

func _process (_delta:float) -> void:
	## Make sure that the export vars and get_nodes have all loaded
	if(BrightnessSlider!=null&&SoundMenuBackButton!=null):
		BackButton.pressed.connect(func(): self.visible = false)
		SoundButton.pressed.connect(func(): SoundSubMenu.visible = true)
		SoundMenuBackButton.pressed.connect(func(): SoundSubMenu.visible = false)
		master_bus_db = AudioServer.get_bus_volume_db(0)
		SoundSlider.value_changed.connect(_master_volume_changed)
		BrightnessSlider.value_changed.connect(func(): Global.set_brightness(BrightnessSlider.value))
		
func _master_volume_changed() -> void:
	AudioServer.set_bus_volume_db(0,master_bus_db*SoundSlider.value/100)
	
