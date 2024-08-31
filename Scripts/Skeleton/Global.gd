extends Node

# Tes globals. its fine to use them because kai used them in dunebound, and anyways
# this isnt c++ we dont need to worry about them messing up performance...
# Globals seem like a good idea, remember to static type these variables though ...

var root_node: Node
var current_scene_path: String

func get_slot_password(slot_num: int) -> String:
	var result_string = ""
	
	for i in range(5):
		var semi_random_number := slot_num * 1000 + i * 10000
		semi_random_number *= 56728936588
		semi_random_number ^= 54687279475
		semi_random_number /= 368246
		result_string += str(semi_random_number)
	
	return result_string
