# Owned by: carsonetb
class_name BaseComponent
extends Node

@export_node_path("Entity") var component_container

var component_name: String = ""

func _ready() -> void:
	_ready_base_component()

func _ready_base_component() -> void:
	if !component_container:
		print("WARNING: Component at path " + str(get_path()) + " does not have a container.")
		return
	
	if (!get_node(component_container) is Entity):
		print("WARNING: Component at path " + str(get_path()) + " does not have a container of type entity.")
		return
	
	var component_container_node: Entity = get_node(component_container)
	component_container_node.add_component(component_name, self)
