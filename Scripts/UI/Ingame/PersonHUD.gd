## Displays personal health and oxygen.
class_name PersonalHUD
extends PanelContainer

@onready var health_progress: TextureProgressBar = $MarginContainer/HBoxContainer/HealthVBox/HBoxContainer/HealthProgress
@onready var oxygen_progress: TextureProgressBar = $MarginContainer/HBoxContainer/OxygenVBox/HBoxContainer/OxygenProgress

func _process(delta: float) -> void:
	health_progress.max_value = Global.player.get_diver_max_health()
	health_progress.value = Global.player.get_diver_health()
	oxygen_progress.value = Global.player.get_oxygen()
