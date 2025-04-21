# Should be part of a MissionTree.
class_name Mission
extends Resource

@export var total_civillians_saved_to_complete := 0
@export var mission_filepath: FilePathResource
@export var title: String
@export var description: String
@export var success_state_checker: MissionSuccessStateCheckerSequence

# Path to a saved resource representing another mission.
@export var unlocks: Array[FilePathResource]

# Indicies of missions that will be unlocked in the mission tree (dynamically created)
var unlocks_indices: Array[int]

func debug() -> void:
	Global.print_debug("DEBUG: Mission: Filepath: " + mission_filepath.file)
	Global.print_debug("DEBUG: Mission: Title: " + title)
	Global.print_debug("DEBUG: Mission: Description: " + description)
	for file in unlocks:
		Global.print_debug("DEBUG: Mission: Unlocks: " + file.file)
	for i in unlocks_indices:
		Global.print_debug("DEBUG: Missions: Unlocks (Indicies): " + str(i))
