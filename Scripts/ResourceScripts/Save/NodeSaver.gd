class_name NodeSaver
extends Resource

var variable_properties: Dictionary
var child_properties: Dictionary
var packed_scene: PackedScene
var instantiate_path: String
var parent_path: String
var node_name: String
var scene_override_path: FilePathResource

static func create(mission: MissionRoot, node: Node, properties: Array[String], _child_properties: Dictionary = {}, scene_override: FilePathResource = null):
	var ret := NodeSaver.new()
	ret.save_node(mission, node, properties, _child_properties, scene_override)
	return ret

func load_node(mission: MissionRoot) -> void:
	Global.print_debug("DEBUG: Loading node at path " + str(instantiate_path) + " relative to mission root.")

	var replace := mission.get_node_or_null(instantiate_path)
	if replace:
		replace.queue_free()
	else:
		Global.print_debug("DEBUG: No node to replace at path " + instantiate_path + " relative to mission root.")
	
	var add_to := mission.get_node_or_null(parent_path)
	if !add_to:
		Global.print_error("Failed to load an object at path " + instantiate_path + " relative to mission root")
	
	var to_add: Node
	if !packed_scene:
		to_add = load(scene_override_path.file).instantiate()
	else:
		to_add = packed_scene.instantiate()

	for variable: String in variable_properties.keys():
		to_add.set(variable, variable_properties[variable])
	
	for path in child_properties.keys():
		var child_variables: Dictionary = child_properties[path]
		var node_to_set:= add_to.get_node_or_null(path)
		if !node_to_set:
			Global.print_error("Failed to get a child at path " + str(path) + " relative to a node that is being loaded. Will not be able to set properties to this child.")
			continue
		for variable: String in child_variables.keys():
			node_to_set.set(variable, child_variables[variable])
	
	add_to.add_child(to_add, true)

	# Wait a bit, make sure the node we replaced is fully deleted.
	await add_to.get_tree().create_timer(0.2, false).timeout

	# Ensure node name stays constant, sometimes Godot can put a number after it.
	to_add.name = node_name

# Child properties is path (String): variable names (Array[String]).
func save_node(mission: MissionRoot, node: Node, properties: Array[String], children_properties: Dictionary = {}, scene_override: FilePathResource = null) -> void:
	Global.print_debug("DEBUG: Saving node at path " + str(mission.get_path_to(node)) + " relative to mission root.")

	_recursively_set_owners(node, node)
	
	node_name = node.name
	instantiate_path = mission.get_path_to(node)
	parent_path = mission.get_path_to(node.get_parent())

	if !scene_override:
		packed_scene = PackedScene.new()
		packed_scene.pack(node)
	else:
		scene_override_path = scene_override
		packed_scene = null
	
	for variable in properties:
		variable_properties[variable] = node.get(variable)
	
	for path in children_properties.keys():
		var node_to_use := node.get_node(path)
		var variables_to_save: Array = children_properties[path]
		var child_property_list := {}
		for variable in variables_to_save:
			child_property_list[variable] = node_to_use.get(variable)
		child_properties[path] = child_property_list

func _recursively_set_owners(set_owner_to: Node, recurse_on: Node) -> void:
	for child in recurse_on.get_children():
		child.owner = set_owner_to
		_recursively_set_owners(set_owner_to, child)
	
