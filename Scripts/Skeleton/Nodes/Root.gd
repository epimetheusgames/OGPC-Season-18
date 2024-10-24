extends Node


@export_node_path("Node") var game_skeleton_node
@export_node_path("Control") var ui_root_node
@export_node_path("Node") var game_root_node
@export_node_path("Node2D") var dialog_text_node

func _ready():
	Global.root_node = self
	Global.game_skeleton_node = get_node(game_skeleton_node)
	Global.ui_root_node = get_node(ui_root_node)
	Global.game_root_node = get_node(game_root_node)
	Global.dialog_text_node = get_node(dialog_text_node)

# I would reccomend not doing this ... you lose control over the game!
# I will be using my SaveLoadFramework node for this.
func change_level_to_scene(path: String) -> void:
	get_tree().paused = false
	var game_root: Node = get_node("Game")
	
	for child in game_root.get_children():
		child.queue_free()
	
	game_root.call_deferred("add_child", load(path).instantiate())
	
	Global.current_scene_path = path
