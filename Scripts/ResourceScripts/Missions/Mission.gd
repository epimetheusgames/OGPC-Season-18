# Should be part of a MissionTree.
class_name Mission
extends Resource

@export var mission_filepath: FilePathResource
@export var title: String
@export var description: String
@export var success_state_checker: MissionSuccessStateChecker

# Path to a saved resource representing another mission.
@export var unlocks: Array[FilePathResource]

# Indicies of missions that will be unlocked in the mission tree (dynamically created)
var unlocks_indices: Array[int]

func debug() -> void:
	print("DEBUG: Mission: Filepath: " + mission_filepath.file)
	print("DEBUG: Mission: Title: " + title)
	print("DEBUG: Mission: Description: " + description)
	for file in unlocks:
		print("DEBUG: Mission: Unlocks: " + file.file)
	for i in unlocks_indices:
		print("DEBUG: Missions: Unlocks (Indicies): " + str(i))
