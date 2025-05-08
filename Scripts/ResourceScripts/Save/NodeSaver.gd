class_name NodeSaver
extends Resource

var variable_properties: Dictionary
var child_properties: Dictionary[String, Dictionary]
var packed_scene: PackedScene
var instantiate_path: String
var parent_path: String
var node_name: String
var scene_override_path: FilePathResource
var use_already_existing_node := false

## Static function to create a NodeSaver.
static func create(mission: MissionRoot, node: Node, properties: Array[String], _child_properties: Dictionary = {}, use_already_existing_node := false, scene_override: FilePathResource = null):
	var ret := NodeSaver.new()
	ret.save_node(mission, node, properties, _child_properties, use_already_existing_node, scene_override)
	return ret

## Recursively, ind new nodes in the original that could've been added be the developer,
## then insert those into the loaded one.
func compare_node_trees(from: Node, to: Node, root: Node = null) -> Array[NodePath]:
	if !root:
		root = to

	var ret: Array[NodePath] = []
	for child in to.get_children():
		var test_node := from.get_node_or_null(to.get_path_to(child))
		if test_node:
			ret += compare_node_trees(test_node, child, root)
		else:
			ret.append(root.get_path_to(child))
	
	return ret

## Load the node into the mission after being saved.
func load_node(mission: MissionRoot) -> void:
	Global.print_debug("Loading node at path " + str(instantiate_path) + " relative to mission root.")
	
	var add_to := mission.get_node_or_null(parent_path)
	if !add_to:
		Global.print_error("Failed to load an object at path " + instantiate_path + " relative to mission root")
	
	var replace := mission.get_node_or_null(instantiate_path)
	var to_add: Node
	
	if !use_already_existing_node:
		if !packed_scene:
			to_add = load(scene_override_path.file).instantiate()
		else:
			to_add = packed_scene.instantiate()
		
		if replace:
			var differing_nodes: Array[NodePath] = compare_node_trees(to_add, replace)
			for path in differing_nodes:
				var node := replace.get_node(path)
				var node_parent_path := replace.get_path_to(node.get_parent())
				node.get_parent().remove_child(node)
				to_add.get_node(node_parent_path).add_child(node)

			replace.queue_free()
		else:
			Global.print_debug("No node to replace at path " + instantiate_path + " relative to mission root.")
	else:
		if !replace:
			Global.print_debug("No node to replace at path " + instantiate_path + " but was supposed to use the existing node.")
			return
		to_add = replace
		
	for variable: String in variable_properties.keys():
		to_add.set(variable, variable_properties[variable])
	
	for path in child_properties.keys():
		var child_variables: Dictionary = child_properties[path]
		var node_to_set:= to_add.get_node_or_null(path)
		if !node_to_set:
			Global.print_error("Failed to get a child at path " + str(path) + " relative to " + to_add.name + ". Will not be able to set properties to this child.")
			continue
		for variable: String in child_variables.keys():
			node_to_set.set(variable, child_variables[variable])
	
	if !use_already_existing_node:
		add_to.add_child(to_add, true)

		# Wait a bit, make sure the node we replaced is fully deleted.
		await add_to.get_tree().create_timer(0.2, false).timeout

		# Ensure node name stays constant, sometimes Godot can put a number after it.
		if to_add:
			to_add.name = node_name

## Packs a node into this NodeSaver. Static function for this is create
## Child properties is path (String): variable names (Array[String]).
func save_node(mission: MissionRoot, node: Node, properties: Array[String], children_properties: Dictionary = {}, use_existing_node := false, scene_override: FilePathResource = null) -> void:
	Global.print_debug("DEBUG: Saving node at path " + str(mission.get_path_to(node)) + " relative to mission root.")

	_recursively_set_owners(node, node)
	
	node_name = node.name
	use_already_existing_node = use_existing_node
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
		child_properties[str(path)] = child_property_list

func add_properties(node: Node, properties: Array[String]) -> void:
	for property in properties:
		if node.has_method("get") and node.has_method(property):
			variable_properties[property] = node.get(property)
		else:
			Global.print_error("Node does not have property " + property + " to save.")

## Set all owners to this node for packing.
func _recursively_set_owners(set_owner_to: Node, recurse_on: Node) -> void:
	for child in recurse_on.get_children():
		child.owner = set_owner_to
		_recursively_set_owners(set_owner_to, child)
	
