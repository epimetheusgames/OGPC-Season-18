class_name GameTimeSystem
extends Node

@export var seconds_per_ten_minutes: float

var _hours: int = 0
var _minutes: int = 0
var _days: int = 0

signal day_ended
signal time_changed(hours: int, minutes: int)

func _ready() -> void:
	Global.game_time_system = self
	
	while true:
		await get_tree().create_timer(seconds_per_ten_minutes).timeout
		if get_tree().paused:
			continue
		if _minutes < 50:
			_minutes += 10
		elif _hours < 23:
			_minutes = 0
			_hours += 1
		else:
			_hours = 0
			_minutes = 0
			_days += 1
			day_ended.emit()
		time_changed.emit(_hours, _minutes)
		
		if Global.is_multiplayer_host():
			Global.godot_steam_abstraction.sync_var(self, "_minutes")
			Global.godot_steam_abstraction.sync_var(self, "_hours")
			Global.godot_steam_abstraction.sync_var(self, "_days")

# Returns hours, minutes.
func get_time() -> Array[int]:
	return [_hours, _minutes]

func get_day() -> int:
	return _days

func set_time(hours: int, minutes: int = 0):
	Global.print_debug("Game time overriden, stack printing in terminal.")
	if Global.verbose_debug:
		print_stack()

	_hours = hours
	_minutes = minutes
	time_changed.emit(hours, minutes)
	
func format_time(hours: int, minutes: int) -> String:
	return str(hours) + ":" + (str(minutes) if minutes > 9 else ("0" + str(minutes)))
