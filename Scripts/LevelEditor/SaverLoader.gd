extends Node


@export_node_path("SubViewport") var level_interface_viewport
@export_node_path("ItemList") var entity_nodes
@export_node_path("ItemList") var tilemap_nodes
@export_node_path("ItemList") var static_nodes
@export_node_path("Tree") var node_tree
@export_node_path("TabBar") var tab_bar

var save_path := ""
var save_path_list: Array[String] = []

func _ready():
	for i in range(1000):
		save_path_list.append("")

## Call this function once we're sure the level has been saved.
func clear_level() -> void:
	# Clear tree
	get_node(node_tree).clear()
	
	# Delete nodes
	var level_node_container: Node = get_node(level_interface_viewport).get_node("LevelInterfaceNodesContainer")
	for child in level_node_container.get_children():
		child.queue_free()

## Save the current level.
func save_level(path: String) -> void:
	save_path = path
	
	if path.ends_with("_editor.json"):
		path = path.replace("_editor.json", ".tscn")
	
	# Save level as scene 
	var node_to_save: Node = get_node(level_interface_viewport).get_node("LevelInterfaceNodesContainer")
	
	# Duplicate node (prevents error?)
	node_to_save = node_to_save.duplicate()
	
	# Set node as owner of children
	for child in node_to_save.get_children():
		child.set_owner(node_to_save)
	
	# Continue to save
	var scene := PackedScene.new()
	scene.pack(node_to_save)
	
	ResourceSaver.save(scene, path)
	
	# Save level as JSON so it can be loaded another time.
	var final_data := {
		"saved_entities": [],
		"saved_tilemaps": [],
		"saved_static": [],
		"level_path": "",
	}
	
	var entities: ItemList = get_node(entity_nodes)
	var tilemaps: ItemList = get_node(tilemap_nodes)
	var statics: ItemList = get_node(static_nodes)
	
	for entity_ind in entities.get_item_count():
		var item_text := entities.get_item_text(entity_ind)
		final_data["saved_entities"].append([item_text, EditorGlobal.object_path_conversion[item_text]])
	for tilemap_ind in tilemaps.get_item_count():
		var item_text := tilemaps.get_item_text(tilemap_ind)
		final_data["saved_tilemaps"].append([item_text, EditorGlobal.object_path_conversion[item_text]])
	for static_id in statics.get_item_count():
		var item_text := statics.get_item_text(static_id)
		final_data["saved_statics"].append([item_text, EditorGlobal.object_path_conversion[item_text]])
	
	final_data["level_path"] = path
	
	var stringified_data = JSON.stringify(final_data)
	var file = FileAccess.open(path.split(".")[0] + "_editor.json", FileAccess.WRITE)
	file.store_string(stringified_data)
	file.close()
	
	# Set tab name to level name
	var level_name = path.split(".")[0].split("/")[-1]
	get_node(tab_bar).set_tab_title(get_node(tab_bar).current_tab, level_name)

func _add_to_grid(path: String, nodes_grid: ItemList):
	var scene_name := path.split(".")[0].split("/")[-1]
	
	# Check if scene_name is already in ItemList.
	var name_list: Array[String] = []
	for i in range(nodes_grid.item_count):
		name_list.append(nodes_grid.get_item_text(i))
	
	if name_list.has(scene_name):
		return
	
	nodes_grid.add_item(scene_name)
	EditorGlobal.object_path_conversion[scene_name] = path

# This is nice because we can connect the dialogue straight to this.
func load_level(path: String) -> void:
	save_path = path
	
	# Load file.
	var data_string := FileAccess.get_file_as_string(path)
	var parsed_data = JSON.parse_string(data_string)
	
	# Load the boxes.
	var entities: ItemList = get_node(entity_nodes)
	var tilemaps: ItemList = get_node(tilemap_nodes)
	var statics: ItemList = get_node(static_nodes)
	
	# Add the types that player has hadded in to their boxes.
	for entity in parsed_data["saved_entities"]:
		var entity_nodes_grid: ItemList = get_node(entity_nodes)
		_add_to_grid(entity[1], entity_nodes_grid)
	for tilemap in parsed_data["saved_tilemaps"]:
		var tilemap_nodes_grid: ItemList = get_node(tilemap_nodes)
		_add_to_grid(tilemap[1], tilemap_nodes_grid)
	for static_node in parsed_data["saved_static"]:
		var static_nodes_grid: ItemList = get_node(static_nodes)
		_add_to_grid(static_node[1], static_nodes_grid)
	
	# Delete level interface root and instantiate the scene we load in.
	var level_interace_root_node: Node = get_node(level_interface_viewport).get_node("LevelInterfaceNodesContainer")
	level_interace_root_node.queue_free()
	
	await level_interace_root_node.tree_exited
	
	var new_root_node: Node = load(parsed_data["level_path"]).instantiate()
	get_node(level_interface_viewport).add_child(new_root_node)
	new_root_node.name = "LevelInterfaceNodesContainer"
	
	# Loop through the child nodes and add them to the tree.
	for child in new_root_node.get_children():
		var new_item: TreeItem = get_node(node_tree).create_item(EditorGlobal.node_tree_root_item)
		new_item.set_text(0, child.name)
	
	# Set tab name to level name
	var level_name = path.split(".")[0].split("/")[-1].replace("_editor", "")
	get_node(tab_bar).set_tab_title(get_node(tab_bar).current_tab, level_name)
