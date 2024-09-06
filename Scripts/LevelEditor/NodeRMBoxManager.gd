extends VBoxContainer


var right_clicking_on: TreeItem

@export_node_path("Tree") var side_bar_node_tree
@export_node_path("SubViewport") var level_interface_container

func _on_side_bar_node_tree_item_mouse_selected(mouse_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		visible = true
		position = get_global_mouse_position()
		var tree: Tree = get_node(side_bar_node_tree)
		var item = tree.get_item_at_position(mouse_position)
		right_clicking_on = item

func _on_delete_button_button_up() -> void:
	if right_clicking_on:
		visible = false
		
		# This is super sketchy, but the name of the node shoould be the same as the name of the
		# TreeItem.
		get_node(level_interface_container).get_node("LevelInterfaceNodesContainer").get_node(right_clicking_on.get_text(0)).queue_free()
		right_clicking_on.free()
		right_clicking_on = null
