# Script responsible for saving and loading levels.
extends Node


@export_node_path("Node") var game_container_node_path
@export_node_path("Control") var ui_root_node_path
@export var level_list: Array[FilePathResource]:
	set(val):
		level_list = val
		
		for filepath in level_list:
			if filepath.file == null:
				filepath.file = FilePathResource.new()
@export var save_encrypted := false

func _ready():
	Global.save_load_framework = self

# Saves a GameSave to memory.
func _save_config_file(content: GameSave, slot_num) -> void:
	var config_file = ConfigFile.new()
	config_file.set_value("Main", "GameSave", content)
	
	if save_encrypted:
		config_file.save_encrypted_pass("user://slot_" + str(slot_num), Global.get_slot_password(int(slot_num)))
	else:
		config_file.save("user://slot_" + str(slot_num))

func _save_global_config(content: GlobalSave) -> void:
	var config_file = ConfigFile.new()
	config_file.set_value("Main", "GlobalSave", content)
	config_file.save("user://global")

# Loads a GameSave from memory.
func _load_config_file(slot_num) -> GameSave:
	var blank_config = ConfigFile.new()
	var slot_path = "user://slot_" + str(slot_num)
	
	var load_error := blank_config.load_encrypted_pass(slot_path, Global.get_slot_password(int(slot_num)))
	
	if load_error == OK:
		print("DEBUG: Config file for save slot " + str(slot_num) + " loaded successfully")
	else:
		print("WARNING: Load error for save slot " + str(slot_num) + ". This WILL cause errors.")
		print("DEBUG: Trying to load data as if it was unencrypted, this may solve the problem.")
		
		load_error = blank_config.load(slot_path)
		
		if load_error == OK:
			print("DEBUG: Loading successful, ignore warning.")
		else:
			print("ERROR: Loading unsuccessful, this means there is a problem with the format of the file.")
			print("DEBUG: If the file is encrypted, you will probably have to delete it, but game data will be erased.")
	
	var game_save: GameSave = blank_config.get_value("Main", "GameSave")
	return game_save

func _load_global_config() -> GlobalSave:
	var blank_config = ConfigFile.new()
	var slot_path = "user://global"
	
	blank_config.load(slot_path)
	
	var game_save: GlobalSave = blank_config.get_value("Main", "GlobalSave")
	return game_save

# Loads a level and then adds it to the Game container.
func start_game(slot_num: int) -> void:
	var level_data := _load_config_file(slot_num)
	
	var ui_generator = get_node(ui_root_node_path).get_node("UIGenerator")
	if !ui_generator:
		print("WARNING: SaveLoadFramework contains no UI Generator node path. Level won't start")
		return
	
	ui_generator.toggle_ui()
	
	var game_container: Node = get_node(game_container_node_path)
	if !game_container:
		print("WARNING: SaveLoadFramework contains no game container node path. Level won't start.")
		return
		
	if level_data.level > level_list.size():
		print("WARNING: Level index is greater than the ammount of levels. Level won't start.")
		return
	
	var game_scene = load(level_list[level_data.level].file)
	game_container.add_child(game_scene)

func exit_to_menu(save_slot: int, game_data: GameSave) -> void:
	_save_config_file(game_data, save_slot)
	
	var game_container: Node = get_node(game_container_node_path)
	for child in game_container.get_children():
		child.queue_free()
	
	var ui_generator: Node = get_node(ui_root_node_path).get_node("UIGenerator")
	
	ui_generator.toggle_ui()
	
