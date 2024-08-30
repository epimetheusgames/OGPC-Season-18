extends Node

func _ready():
	Global.root_node = self

func change_level_to_scene(path: String) -> void:
	get_tree().paused = false
	var game_root: Node = get_node("Game")
	
	for child in game_root.get_children():
		child.queue_free()
	
	game_root.call_deferred("add_child", load(path).instantiate())
	
	Global.current_scene_path = path
