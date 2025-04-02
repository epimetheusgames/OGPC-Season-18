class_name GameTimeSystem
extends Node

@export var seconds_per_ten_minutes: int

var _hours: int = 0
var _minutes: int = 0

signal day_ended
signal time_changed(hours: int, minutes: int)

func _ready() -> void:
	Global.game_time_system = self
	
	while true:
		await get_tree().create_timer(seconds_per_ten_minutes).timeout
		if _minutes < 60:
			_minutes += 10
		elif _hours < 23:
			_minutes = 0
			_hours += 1
		else:
			_hours = 0
			_minutes = 0
			day_ended.emit()
		time_changed.emit(_hours, _minutes)

# Returns hours, minutes.
func get_time() -> Array[int]:
	return [_hours, _minutes]

func set_time(hours: int, minutes: int = 0):
	Global.print_debug("Game time overriden, stack printing in terminal.")
	if Global.verbose_debug:
		print_stack()

	_hours = hours
	_minutes = minutes
	time_changed.emit(hours, minutes)
	
func format_time(hours: int, minutes: int) -> String:
	return str(hours) + ":" + (str(minutes) if minutes > 9 else ("0" + str(minutes)))
