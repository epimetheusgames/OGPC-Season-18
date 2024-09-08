extends Camera2D

@export_node_path("SubViewport") var level_interface_viewport
@export_node_path("VBoxContainer") var entity_tree_container
@export_node_path("VBoxContainer") var tilemap_tree_container
@export_node_path("VBoxContainer") var static_tree_container
@export_node_path("VBoxContainer") var side_bar_tree_container
@export_node_path("Node") var level_interface_node_container

var mouse_middle_down := false

func _process(delta: float) -> void:
	if Input.is_action_pressed("mouse_middle"):
		position -= Input.get_last_mouse_velocity() / 100 * delta * 60 * (Vector2.ONE / zoom)
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom *= 1.1
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom /= 1.1

func _instantiate_add_node_icon(nodes_grid: ItemList, index: int):
	var item_name := nodes_grid.get_item_text(index)
	var node_path: String = EditorGlobal.object_path_conversion[item_name]
	var add_node_icon := load("res://Scenes/TSCN/Levels/Editor/MouseFollowAddNodeIcon.tscn")
	var instantiated_add_node_icon: Node2D = add_node_icon.instantiate()
	
	instantiated_add_node_icon.instantiated_node_path = node_path
	instantiated_add_node_icon.node_tree = get_node(side_bar_tree_container).get_node("SideBarNodeTree")
	get_node(level_interface_node_container).add_child(instantiated_add_node_icon)

func _on_entity_nodes_item_activated(index: int) -> void:
	var entity_nodes_grid: ItemList = get_node(entity_tree_container).get_node("EntityNodes")
	_instantiate_add_node_icon(entity_nodes_grid, index)

func _on_static_nodes_item_activated(index: int) -> void:
	var static_nodes_grid: ItemList = get_node(static_tree_container).get_node("StaticNodes")
	_instantiate_add_node_icon(static_nodes_grid, index)

func _on_side_bar_node_tree_item_mouse_selected(mouse_position: Vector2, mouse_button_index: int) -> void:
	# Again this is sketchy, but it should work.
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		var side_bar_tree: Tree = get_node(side_bar_tree_container).get_node("SideBarNodeTree")
		var tree_item := side_bar_tree.get_item_at_position(mouse_position)
		var level_interface_node_container = get_parent().get_node("LevelInterfaceNodesContainer")
		var node_selected: Node = level_interface_node_container.get_node(tree_item.get_text(0))
		
		if !node_selected is Node2D:
			return
		
		var object_manipulator = get_parent().get_node("ObjectManipulator")
		object_manipulator.set_object(node_selected)
