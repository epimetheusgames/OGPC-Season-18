class_name MissionSuccessStateCheckerSequence
extends Resource

@export var sequence: Array[MissionSuccessStateChecker]
var index := 0

func initialize(diver: Diver) -> void:
	for item in sequence:
		item.initialize(diver)

func check_success() -> bool:
	if sequence[index].check_success():
		if Global.verbose_debug:
			print("DEBUG: Mission sub-state completed. Description: " + sequence[index].description)
		index += 1
		if index >= sequence.size():
			index -= 1
			return true
	return false

func get_description() -> String:
	return sequence[index].description
