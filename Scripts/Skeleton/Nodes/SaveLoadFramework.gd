# Script responsible for saving and loading levels.
class_name SaveLoadFramework
extends Node


@export var game_container: Node
@export_node_path("Control") var ui_root_node_path
@export var level_list: Array[FilePathResource]:
	set(val):
		level_list = val
		
		for filepath in level_list:
			if filepath == null:
				filepath = FilePathResource.new()
@export var save_encrypted := false

func _ready():
	Global.save_load_framework = self
	
	#load_level("res://Scenes/TSCN/Levels/Missions/Mission1.tscn")
	load_level("res://Scenes/TSCN/Levels/kai_test.tscn")
# Saves a ConfigFile to memory.
func _save_config_file(config_file: ConfigFile, slot_num: int) -> void:
	if save_encrypted:
		config_file.save_encrypted_pass("user://slot_" + str(slot_num), Global.get_slot_password(slot_num))
	else:
		config_file.save("user://slot_" + str(slot_num))

# Saves a GameSave to memory.
func _save_game_save(content: GameSave, slot_num: int) -> void:
	var config_file := ConfigFile.new()
	config_file.set_value("Main", "GameSave", content)
	_save_config_file(config_file, slot_num)

# Save global config to memory.
func _save_global_config(content: GlobalSave) -> void:
	var config_file = ConfigFile.new()
	config_file.set_value("Main", "GlobalSave", content)
	config_file.save("user://global")

# Save an entity state to its slot.
func _save_entity(slot_num: int, uid: UID, content: EntitySave) -> void:
	var config_file := _load_config_file(slot_num)
	config_file.set_value("Entities", str(uid.uid), content)
	_save_config_file(config_file, slot_num)

func _load_config_file(slot_num) -> ConfigFile:
	var blank_config := ConfigFile.new()
	var slot_path := "user://slot_" + str(slot_num)
	
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
			print("DEBUG: If the file is encrypted, you will probably have to delete it, and game data will be erased.")
	
	return blank_config

# Loads a GameSave from memory.
func _load_game_save(slot_num: int) -> GameSave:
	var blank_config := _load_config_file(slot_num)
	var game_save: GameSave = blank_config.get_value("Main", "GameSave")
	return game_save

# Loads the global save from memory.
func _load_global_config() -> GlobalSave:
	var blank_config = ConfigFile.new()
	var slot_path := "user://global"
	
	blank_config.load(slot_path)
	
	var game_save: GlobalSave = blank_config.get_value("Main", "GlobalSave")
	return game_save

# Loads an entity from memory with a UID.
func _load_entity(slot_num: int, uid: UID) -> EntitySave:
	var config_file := _load_config_file(slot_num)
	return config_file.get_value("Entities", str(uid.uid))

# Loads a level and then adds it to the Game container.
func start_game(slot_num: int) -> void:
	var level_data := _load_game_save(slot_num)
		
	if level_data.level > level_list.size():
		print("WARNING: Level index is greater than the ammount of levels. Level won't start.")
		return
	
	Global.current_game_slot = slot_num
	
	load_level(level_list[level_data.level].file)

func load_level(level_path: String):
	if !ui_root_node_path:
		print("WARNING: SaveLoadFramework contains no UI root node path. UI actions won't run.")
	else:
		var ui_generator: Node = get_node(ui_root_node_path).get_node("UIGenerator")
		if !ui_generator:
			print("WARNING: SaveLoadFramework contains no UI Generator node path. UI actions won't run.")
		
		else: 
			ui_generator.toggle_ui()
	
	if !game_container:
		print("WARNING: SaveLoadFramework contains no game container node path. Level won't start.")
		return
	
	var level_loaded := load(level_path)
	var instantiated = level_loaded.instantiate()
	game_container.add_child(instantiated)
	instantiated.owner = game_container

# Close and save game and exit to menu.
func exit_to_menu(save_slot: int, game_data: GameSave) -> void:
	_save_game_save(game_data, save_slot)
	
	for child in game_container.get_children():
		child.queue_free()
	
	if !ui_root_node_path:
		print("WARNING: SaveLoadFramework contains no UI root node, no menu to exit to.")
		return
	
	var ui_generator: Node = get_node(ui_root_node_path).get_node("UIGenerator")
	
	if !ui_generator:
		print("WARNING: SaveLoadFramework contains no UI generator path, no menu to exit to.")
		return

	ui_generator.toggle_ui()
	
