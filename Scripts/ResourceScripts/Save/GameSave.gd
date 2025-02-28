extends Resource
class_name GameSave

@export var slot: int
@export var unlocked_mission_tree: MissionTreeProgress
@export var node_saves: Array[NodeSaver]

func debug() -> void:
	print("DEBUG: GameSave: Slot: " + str(slot))
	print("DEBUG: GameSave: unlocked_mission_tree debug:")
	unlocked_mission_tree.debug()
