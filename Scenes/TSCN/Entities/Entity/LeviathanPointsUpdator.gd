extends Node2D


func _process(delta: float) -> void:
	for i in range(get_parent().leviathan_nodes.size() - 1):
		get_parent().leviathan_nodes[i + 1].global_position = get_parent().rope_component.points[i]
