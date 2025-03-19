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

func complete_mission(mission: Mission) -> void:
	if !mission_tree.get_mission_by_resource(mission):
		Global.print_error("A MissionTreeProgress complete mission was asked to complete a mission (" + mission.title + "), but that mission was not in the tree. Printing stack (stack in console only).")
		print_stack()
		return
	
	completed.append(mission)

func debug() -> void:
	Global.print_debug("DEBUG: MissionTreeProgress: MissionTree:")
	for mission in mission_tree.missions:
		mission.debug()
	Global.print_debug("DEBUG: MissionTreeProgress: Completed")
	for mission in completed:
		mission.debug()
	Global.print_debug("DEBUG: MissionTreeProgress: Available:")
	for mission in get_available_missions():
		mission.debug()
