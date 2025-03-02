extends Resource
class_name GameSave

@export var slot: int
@export var unlocked_mission_tree: MissionTreeProgress
@export var node_saves: Array[NodeSaver]

func debug() -> void:
	Global.print_debug("DEBUG: GameSave: Slot: " + str(slot))
	Global.print_debug("DEBUG: GameSave: Unlocked Mission Tree:")
	unlocked_mission_tree.debug()
