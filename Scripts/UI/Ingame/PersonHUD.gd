## Displays personal health and oxygen.
class_name PersonalHUD
extends PanelContainer

@onready var health_progress: TextureProgressBar = $MarginContainer/HBoxContainer/HealthVBox/HBoxContainer/HealthProgress
@onready var oxygen_progress: TextureProgressBar = $MarginContainer/HBoxContainer/OxygenVBox/HBoxContainer/OxygenProgress
@onready var time: Label = $MarginContainer/HBoxContainer/TimeText

func _ready() -> void:
	if Global.game_time_system:
		Global.game_time_system.time_changed.connect(_time_changed)
	
	if Global.save_load_framework:
		Global.save_load_framework.save_nodes.connect(_saving_game)

func _process(_delta: float) -> void:
	health_progress.value = Global.player.get_diver_health()
	oxygen_progress.value = Global.player.get_oxygen()
	
	$MarginContainer/HBoxContainer/MoneyStatus.text = "Money: " + str(Global.player.diver_stats.current_money)
	
	if Global.player.diver_movement.is_in_research_station:
		$MarginContainer/HBoxContainer/Seperator2.visible = true
		$MarginContainer/HBoxContainer/MoneyStatus.visible = true
	else:
		$MarginContainer/HBoxContainer/Seperator2.visible = false
		$MarginContainer/HBoxContainer/MoneyStatus.visible = false

func _saving_game() -> void:
	$MarginContainer/HBoxContainer/SavingText.visible = true
	$MarginContainer/HBoxContainer/Seperator.visible = true

	await get_tree().create_timer(2).timeout

	$MarginContainer/HBoxContainer/SavingText.visible = false
	$MarginContainer/HBoxContainer/Seperator.visible = false

func _time_changed(hour: int, minute: int):
	time.text = "Current Time: " + Global.game_time_system.format_time(hour, minute)
