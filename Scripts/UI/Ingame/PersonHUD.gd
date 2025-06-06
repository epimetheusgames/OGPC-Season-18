## Displays personal health and oxygen.
class_name PersonalHUD
extends PanelContainer

@onready var health_progress: TextureProgressBar = $MarginContainer/HBoxContainer/HealthVBox/HBoxContainer/HealthProgress
@onready var oxygen_progress: TextureProgressBar = $MarginContainer/HBoxContainer/OxygenVBox/HBoxContainer/OxygenProgress
@onready var time: Label = $MarginContainer/HBoxContainer/TimeText
@onready var warning_text: Label = $MarginContainer/HBoxContainer/WarningText
var oxygen_low := false

func _ready() -> void:
	if Global.game_time_system:
		Global.game_time_system.time_changed.connect(_time_changed)
	
	if Global.save_load_framework:
		Global.save_load_framework.save_nodes.connect(_saving_game)
	if(Global.research_station):
		Global.research_station.follower_spawned.connect(_spawning_follower)

func _process(_delta: float) -> void:
	health_progress.value = Global.player.get_diver_health()
	oxygen_progress.value = Global.player.get_oxygen()
	
	$MarginContainer/HBoxContainer/MoneyStatus.text = "Money: " + str(Global.player.diver_stats.current_money)
	
	var readable_pos := (Global.player.global_position - Global.research_station.global_position) / 10
	$MarginContainer/HBoxContainer/CoordsText.text = "Coordinates: " + str(int(readable_pos.x)) + ", " + str(int(readable_pos.y))
	
	$MarginContainer/HBoxContainer/SavedCivillians.text = "Saved Civillians: " + str(Global.current_mission_node.total_saved_civillians)
	
	if Global.player.get_oxygen() <= 25 && !oxygen_low:
		_oxygen_low()

func _saving_game() -> void:
	$MarginContainer/HBoxContainer/SavingText.visible = true
	$MarginContainer/HBoxContainer/Seperator.visible = true

	await get_tree().create_timer(2).timeout

	$MarginContainer/HBoxContainer/SavingText.visible = false
	$MarginContainer/HBoxContainer/Seperator.visible = false

func _time_changed(hour: int, minute: int):
	time.text = "Current Time: " + Global.game_time_system.format_time(hour, minute)
	
func _oxygen_low() -> void:
	oxygen_low = true
	while Global.player.diver_stats.oxygen <= 25:
		warning_text.text = "Oxygen Low!"
		await get_tree().create_timer(1).timeout
		warning_text.text = ""
		await get_tree().create_timer(1).timeout
	oxygen_low = false

func _spawning_follower(pos: Vector2) -> void:
	for i in range(30):
		if Global.player.diver_stats.oxygen <= 25:
			return
		var sanitized := (pos - Global.research_station.global_position) / 10.0
		warning_text.text = "Civillians have spawned at the coordinates " + str(int(sanitized.x)) + ", " + str(int(sanitized.y))
		await get_tree().create_timer(1).timeout
		warning_text.text = ""
		await get_tree().create_timer(1).timeout
