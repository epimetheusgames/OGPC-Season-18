## Displays personal health and oxygen.
class_name PersonalHUD
extends PanelContainer

@onready var health_progress: TextureProgressBar = $MarginContainer/HBoxContainer/HealthVBox/HBoxContainer/HealthProgress
@onready var oxygen_progress: TextureProgressBar = $MarginContainer/HBoxContainer/OxygenVBox/HBoxContainer/OxygenProgress
@onready var time: Label = $MarginContainer/HBoxContainer/TimeText

func _ready() -> void:
	if Global.game_time_system:
		Global.game_time_system.time_changed.connect(_time_changed)

func _process(delta: float) -> void:
	health_progress.max_value = Global.player.get_diver_max_health()
	health_progress.value = Global.player.get_diver_health()
	oxygen_progress.value = Global.player.get_oxygen()

func _time_changed(hour: int, minute: int):
	time.text = "Current Time: " + Global.game_time_system.format_time(hour, minute)
