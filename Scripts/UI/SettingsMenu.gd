extends Control
var master_bus_db
@onready var backButton = get_node("backButton")
@onready var masterVolumeSlider = get_node("soundSubMenu/HBoxContainer/VBoxContainer/volumeSlider")
@onready var soundButton = get_node("HBoxContainer/VBoxContainer/soundButton")
@onready var soundSubMenu = get_node("soundSubMenu")
@onready var soundMenuBackButton = get_node("soundSubMenu/backButton")
@export var brightnessSlider: HSlider
@export var performanceButton: Button
@export var soundSlider: HSlider
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	backButton.pressed.connect(func(): self.visible = false)
	soundButton.pressed.connect(func(): soundSubMenu.visible = true)
	soundMenuBackButton.pressed.connect(func(): soundSubMenu.visible = false)
	performanceButton.pressed.connect(func(): Global.current_mission_node.turn_on_efficient())
	master_bus_db = AudioServer.get_bus_volume_db(0)
	soundSlider.value_changed.connect(_master_volume_changed)
	brightnessSlider.value_changed.connect(func(): Global.set_brightness(brightnessSlider.value))
func _master_volume_changed() -> void:
	AudioServer.set_bus_volume_db(0,master_bus_db*masterVolumeSlider.value/100)
	
