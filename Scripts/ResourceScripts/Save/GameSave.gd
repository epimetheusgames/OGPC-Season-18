extends Resource
class_name GameSave

@export var slot: int
@export var unlocked_mission_tree: MissionTreeProgress

# UID (int) : EntitySave
@export var entities: Dictionary = {}

func debug() -> void:
	print("DEBUG: GameSave: Slot: " + str(slot))
	for key in entities.keys():
		print("DEBUG: GameSave: Entities: Key " + str(key) + ", Value:")
		entities[key].debug()
	print("DEBUG: GameSave: unlocked_mission_tree debug:")
	unlocked_mission_tree.debug()
