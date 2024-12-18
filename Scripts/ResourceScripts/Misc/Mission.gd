# Should be part of a MissionTree.
class_name Mission
extends Resource

@export var mission_filepath: FilePathResource
@export var title: String
@export var description: String

# Path to a saved resource representing another mission.
@export var unlocks: Array[FilePathResource]

# Indicies of missions that will be unlocked in the mission tree (dynamically created)
var unocks_indices: Array[int]
