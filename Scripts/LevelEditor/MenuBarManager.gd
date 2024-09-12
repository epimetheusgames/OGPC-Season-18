extends MenuBar


var opening_entity := false
var opening_tilemap := false
var opening_static := false

@export_node_path("SubViewport") var level_interface_viewport
@export_node_path("VBoxContainer") var entity_tree_container
@export_node_path("VBoxContainer") var tilemap_tree_container
@export_node_path("VBoxContainer") var static_tree_container
@export_node_path("Node") var saver_loader
@export_node_path("Node2D") var object_manipulator

# File dialogue
func _on_file_id_pressed(id: int) -> void:
	if id == 0 || id == 2:
		if !get_node(saver_loader).save_path:
			var level_save_dialog: FileDialog = get_parent().get_node("LevelSaveDialog")
			level_save_dialog.visible = true
		else:
			get_node(saver_loader).save_level(get_node(saver_loader).save_path)
	if id == 1:
		var level_load_dialog: FileDialog = get_parent().get_node("LevelLoadDialog")
		level_load_dialog.visible = true
	if id == 2:
		var tab_bar: TabBar = get_parent().get_node("TabBar")
		tab_bar.add_tab("Empty Level")
		tab_bar.current_tab = tab_bar.tab_count - 1
		tab_bar.tab_close_display_policy = TabBar.CLOSE_BUTTON_SHOW_ACTIVE_ONLY
		
		get_node(saver_loader).save_path_list[tab_bar.current_tab - 1] = get_node(saver_loader).save_path
		
		# Everything's saved, we can do this now!
		get_node(saver_loader).clear_level()
		get_node(saver_loader).save_path = ""

# Edit dialogue
func _on_edit_id_pressed(id: int) -> void:
	if id == 0 || id == 2:
		get_parent().get_node("EntityImportFileDialog").visible = true
	else:
		get_parent().get_node("TileMapImportFileDialog").visible = true
	
	if id == 0:
		opening_entity = true
		opening_tilemap = false
		opening_static = false
	if id == 1:
		opening_entity = false
		opening_tilemap = true
		opening_static = false
	if id == 2:
		opening_entity = false
		opening_tilemap = false
		opening_static = true
	if id == 3:
		get_parent().get_node("TileMapImportFileDialog").visible = false
		get_parent().get_node("SnappingPopup").visible = true

func _add_to_grid(path: String, nodes_grid: ItemList):
	var scene_name := path.split(".")[0].split("/")[-1]
	nodes_grid.add_item(scene_name)
	EditorGlobal.object_path_conversion[scene_name] = path

func _on_entity_import_file_dialog_file_selected(path: String) -> void:
	if opening_entity:
		var entity_nodes_grid: ItemList = get_node(entity_tree_container).get_node("EntityNodes")
		_add_to_grid(path, entity_nodes_grid)
	if opening_tilemap:
		var tilemap_nodes_grid: ItemList = get_node(tilemap_tree_container).get_node("TileMapNodes")
		_add_to_grid(path, tilemap_nodes_grid)
	if opening_static:
		var static_nodes_grid: ItemList = get_node(static_tree_container).get_node("StaticNodes")
		_add_to_grid(path, static_nodes_grid)

func _on_level_save_dialog_file_selected(path: String) -> void:
	get_node(saver_loader).save_level(path)

func _on_snapping_popup_id_pressed(id: int) -> void:
	var snapping_id_px_converter := {
		0: 4,
		1: 8,
		2: 16,
		3: 32,
		4: 64,
	}
	get_node(object_manipulator).snapping_ammount = snapping_id_px_converter[id]

func _on_tab_bar_tab_close_pressed(tab: int) -> void:
	var saver: Node = get_node(saver_loader)
	var tabs: TabBar = get_parent().get_node("TabBar")
	
	# Save level, clear it, remove tab, and switch to the level we switched to.
	_on_file_id_pressed(0)
	saver.clear_level()
	tabs.remove_tab(tab)
	get_parent()._ready()
	saver.load_level(saver.save_path_list[tabs.current_tab])

func _on_tab_bar_tab_changed(tab: int) -> void:
	var saver: Node = get_node(saver_loader)
	var tabs: TabBar = get_parent().get_node("TabBar")
	
	if tabs.get_tab_title(tabs.current_tab) == "Empty Level":
		saver.clear_level()
		get_parent().call_deferred("_ready")
		return
	
	# Save level clear it, and load the next level.
	_on_file_id_pressed(0)
	saver.save_path = saver.save_path_list[tabs.current_tab]
	saver.clear_level()
	get_parent()._ready()
	saver.load_level(saver.save_path_list[tabs.current_tab])
