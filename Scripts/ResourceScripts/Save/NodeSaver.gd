class_name NodeSaver
extends Resource

var variable_properties: Dictionary
var packed_scene: PackedScene
var instantiate_path: String
var parent_path: String

static func create(mission: MissionRoot, node: Node, scene: FilePathResource, properties: Array[String]):
	var ret := NodeSaver.new()
	ret.save_node(mission, node, scene, properties)
	return ret

func load_node(mission: MissionRoot) -> void:
	var replace := mission.get_node_or_null(instantiate_path)
	if replace:
		replace.queue_free()
	
	var add_to := mission.get_node_or_null(parent_path)
	if !add_to:
		print("ERROR: Failed to load an object at path " + instantiate_path + " relative to mission root.")
	
	var to_add: Node = packed_scene.instantiate()
	for variable in variable_properties.keys():
		to_add.set(variable, variable_properties[variable])
	
	add_to.add_child(to_add, true)

func save_node(mission: MissionRoot, node: Node, scene: FilePathResource, properties: Array[String]) -> void:
	for a in node.get_children():
		a.owner = node
		for b in a.get_children():
			b.owner = node
			for c in b.get_children():
				c.owner = node
	
	instantiate_path = mission.get_path_to(node)
	parent_path = mission.get_path_to(node.get_parent())
	packed_scene = PackedScene.new()
	packed_scene.pack(node)
	
	for variable in properties:
		variable_properties[variable] = node.get(variable)
