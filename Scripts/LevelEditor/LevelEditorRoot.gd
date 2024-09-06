extends GridContainer


@export_node_path("Tree") var side_bar_node_tree

func _ready() -> void:
	get_tree().paused = true
	var root_item: TreeItem = get_node(side_bar_node_tree).create_item()
	root_item.set_text(0, "root")
	EditorGlobal.node_tree_root_item = root_item
