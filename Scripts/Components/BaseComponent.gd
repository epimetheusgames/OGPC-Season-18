class_name BaseComponent
extends Node


var component_name = "BaseComponent"

@export_node_path("Entity") var component_container

func _ready() -> void:
	_base_component_ready_post()

func _base_component_ready_post() -> void:
	if (!get_node(component_container) is Entity):
		print("WARNING: Component at path " + str(get_path()) + " does not have a container of type entity.")
		return
	
	var component_container_node: Entity = get_node(component_container)
	component_container_node.add_component(component_name, self)
