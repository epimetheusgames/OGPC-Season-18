class_name MissionTreeProgress
extends Resource

var mission_tree: MissionTree
var completed: Array[Mission] = []

func get_available_missions() -> Array[Mission]:
	var out: Array[Mission] = []
	
	for mission in completed:
		var unlocks := mission_tree.get_mission_unlocks(mission)
		for child in unlocks:
			out.append(child)
	
	return out

func complete_mission(mission: Mission):
	if not mission_tree.get_mission_by_resource(mission):
		print("ERROR: A MissionTreeProgress save resources was asked to complete a mission (" + mission.title + "), but that mission was not in the tree. Printing stack.")
		print_stack()
		return
	completed.append(mission)
