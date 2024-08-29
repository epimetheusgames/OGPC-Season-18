extends Node

func change_level_to_scene(path: String):
	get_tree().paused = false
	
	for child in get_children():
			child.queue_free()
			await child.tree_exited
			
	#why did kai think this was necessary to add when he wrote this in the dunebound codebase!?
	#await get_tree().create_timer(1).timeout
	add_child(load(path).instantiate())
	
	Global.current_scene_path = path
	

func _ready():
	Global.root_node = self
