extends Node2D


var node_tree: Tree
var instantiated_node_path: String
var frames_since_start := 0

func _process(delta: float) -> void:
	frames_since_start += 1
	position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("mouse_left_click") && frames_since_start > 10:
		var loaded_node := load(instantiated_node_path)
		var instantiated_node = loaded_node.instantiate()
		
		if instantiated_node is Node2D:
			instantiated_node.position = position
			
		get_parent().add_child(instantiated_node)
		
		var new_item := node_tree.create_item(EditorGlobal.node_tree_root_item)
		new_item.set_text(0, instantiated_node.name)
		
		queue_free()
