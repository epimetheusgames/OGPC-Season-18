extends Node2D
@onready var master_bus_db = AudioServer.get_bus_volume_db(0)
@onready var MainContainer = get_node("ContainTheDumbShit")
@onready var BackButton = MainContainer.get_node("BackButton")
@onready var SoundButton = MainContainer.get_node("HBoxContainer/VBoxContainer/SoundButton")
@onready var SoundSubMenu = get_node("SoundSubMenu")
@onready var SoundMenuBackground = get_node("SoundMenuBackground")
@onready var SoundMenuBackButton = get_node("SoundSubMenu/BackButton")
@export var BrightnessSlider: HSlider
@export var PerformanceButton: Button
@export var SoundSlider: HSlider
## I really wish godot had a way to run code after every other node is ready
var HasCodeRan:bool = false

func _process (_delta:float) -> void:
	## Make sure that the export vars and get_nodes have all loaded
	if(!HasCodeRan&&BrightnessSlider!=null&&SoundMenuBackButton!=null):
		BackButton.pressed.connect(func(): self.visible = false)
		SoundButton.pressed.connect(_open_sound_button)
		SoundMenuBackButton.pressed.connect(_close_sound_button)
		master_bus_db = AudioServer.get_bus_volume_db(0)
		HasCodeRan = true
		
func _master_volume_changed(value) -> void:
	AudioServer.set_bus_volume_linear(0,SoundSlider.value)
func _brightness_slider_value_changed(value) -> void:
	Global.set_brightness(BrightnessSlider.value)

func _open_sound_button() -> void:
	SoundMenuBackground.visible = true
	SoundSubMenu.visible = true
func _close_sound_button() -> void:
	SoundMenuBackground.visible = false
	SoundSubMenu.visible = false
