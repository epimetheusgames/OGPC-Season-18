extends Node


func _ready() -> void:
	if !FileAccess.file_exists("user://level_paths.json"):
		FileAccess.open("user://level_paths.json", FileAccess.WRITE)
	
	var levels_path_save_file := FileAccess.open("user://level_paths.json", FileAccess.READ_WRITE)
	var paths_data := _get_level_list_data(levels_path_save_file)
	
	for path in paths_data:
		_add_level_list_row(path)

func _get_level_list_data(save_file: FileAccess) -> Array:
	var paths_string: String = save_file.get_as_text()
	if paths_string == "":
		paths_string = "[]"
		save_file.store_string(paths_string)
	
	var paths_data: Array = JSON.parse_string(paths_string)
	return paths_data

func _add_level_list_row(path: String) -> void:
	var new_level_box: HBoxContainer = $SelectLevelPopup/LevelsList/TemplateLevelBox.duplicate()
	new_level_box.get_node("Name").text = path.replace(".json", "").split("/")[-1]
	new_level_box.get_node("Path").text = path
	new_level_box.visible = true
	$SelectLevelPopup/LevelsList.add_child(new_level_box)
	
	var load_button: Button = new_level_box.get_node("LoadButton")
	load_button.connect("button_up", _on_load_button_button_up.bind(path))

func _on_window_close_requested() -> void:
	$SelectLevelPopup.visible = false

func _on_add_level_button_button_up() -> void:
	$SelectLevelPopup/LevelsListAddLevelFileDialog.visible = true

func _on_levels_list_add_level_file_dialog_file_selected(path: String) -> void:
	_add_level_list_row(path)
	
	var levels_path_save_file := FileAccess.open("user://level_paths.json", FileAccess.READ_WRITE)
	var paths_data := _get_level_list_data(levels_path_save_file)
	var paths_string := levels_path_save_file.get_as_text()
	
	paths_data.append(path)
	
	paths_string = JSON.stringify(paths_data)
	levels_path_save_file.store_string(paths_string)

func _on_load_button_button_up(level_path: String) -> void:
	$SelectLevelPopup.visible = false
	
	# Open empty level and load level path.
	if !$LevelEditorUIGrid/TabBar.get_tab_title($LevelEditorUIGrid/TabBar.current_tab) == "Empty Level":
		$LevelEditorUIGrid/MenuBar._on_file_id_pressed(2)
	$SaverLoader.load_level(level_path)
	
	# Set this to be invisible since we aren't actually prompting for an empty level.
	$LevelEditorUIGrid/LevelLoadDialog.visible = false
