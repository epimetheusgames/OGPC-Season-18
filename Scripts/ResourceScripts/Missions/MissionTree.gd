# A tree of missions, with helper functions.
class_name MissionTree
extends Resource

@export var missions: Array[Mission]

func get_mission_by_resource(resc: Mission) -> int:
	return missions.find(resc)

func get_mission_unlocks(resc: Mission) -> Array[Mission]:
	var out: Array[Mission] = []
	for mission in resc.unlocks:
		out.append(load(mission.file))
	return out

func get_mission_unlocks_index(resc: int) -> Array[Mission]:
	return get_mission_unlocks(missions[resc])
