# Script responsible for saving and loading levels.
# Owned by: carsonetb
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
@export var default_level: FilePathResource

signal game_started(slot_num: int)
signal save_nodes
signal on_exit_to_menu

enum LOAD_ERROR {
	OK,
	NEEDS_INITIALIZATION,
	CORRUPTED,
}

func _ready():
	Global.save_load_framework = self
	
	#load_level("res://Scenes/TSCN/Levels/Missions/Mission1.tscn")
	#load_level("res://Scenes/TSCN/Levels/basic_test.tscn")

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
func _save_entity(uid: UID, content: EntitySave) -> void:
	if Global.current_game_save == null:
		Global.print_error("Attempting to save an entity while in the main menu. Printing stack (in console).")
		print_stack()
		return

	Global.current_game_save.entities[uid.uid] = content
	save_state()

# Save the current game state.
func save_state(call_signal := true) -> void:
	if Global.current_game_save == null || Global.current_game_slot == -1:
		Global.print_error("Attempting to save state while in the main menu. Printing stack (in console).")
		print_stack()
		return
	
	# Otherwise it's research station.
	if Global.current_mission_node is MissionRoot && call_signal:
		Global.current_game_save.node_saves = []
		save_nodes.emit()
	_save_game_save(Global.current_game_save, Global.current_game_slot)

func _load_config_file(slot_num) -> Array:
	var blank_config := ConfigFile.new()
	var slot_path := "user://slot_" + str(slot_num)
	
	var load_error := blank_config.load_encrypted_pass(slot_path, Global.get_slot_password(int(slot_num)))
	var return_error: LOAD_ERROR
	
	if load_error == OK:
		Global.print_debug("Config file for slot " + str(slot_num) + " loaded successfully.")
		return_error = LOAD_ERROR.OK
	elif load_error == ERR_FILE_NOT_FOUND: return_error = LOAD_ERROR.NEEDS_INITIALIZATION
	else:
		Global.print_debug("Load error for save slot " + str(slot_num) + ". This MIGHT cause errors.")
		Global.print_debug("Trying to load data as if it was unencrypted, this may solve the problem.")
		
		load_error = blank_config.load(slot_path)
		
		if load_error == OK:
			Global.print_debug("Loading successful, ignore warning.")
			return_error = LOAD_ERROR.OK
		else:
			Global.print_error("Loading unsuccessful, this means there is a problem with the format of the file.")
			Global.print_error("If the file is encrypted, you will probably have to delete it, and game data will be erased.")
			return_error = LOAD_ERROR.CORRUPTED
	
	return [blank_config, return_error]

# Loads a GameSave from memory.
func _load_game_save(slot_num: int) -> GameSave:
	var load_info := _load_config_file(slot_num)
	var config: ConfigFile = load_info[0]
	var error: LOAD_ERROR = load_info[1]

	if error == LOAD_ERROR.NEEDS_INITIALIZATION:
		Global.print_debug("Loading a save file that needs initialization.")
		var new_save := GameSave.new()
		var new_mission_tree := MissionTreeProgress.new()
		new_mission_tree.mission_tree = Global.mission_system.default_mission_tree.duplicate()
		new_save.slot = slot_num
		new_save.unlocked_mission_tree = new_mission_tree
		_save_game_save(new_save, slot_num)
		config = _load_config_file(slot_num)[0]

	var game_save: GameSave = config.get_value("Main", "GameSave")
	return game_save

# Loads the global save from memory.
func _load_global_config() -> GlobalSave:
	var blank_config = ConfigFile.new()
	var slot_path := "user://global"
	
	var error: Error = blank_config.load(slot_path)
	
	if error == ERR_FILE_CANT_OPEN:
		return GlobalSave.new()
	
	var game_save: GlobalSave = blank_config.get_value("Main", "GlobalSave", GlobalSave.new())
	return game_save

# Loads an entity from memory with a UID.
func _load_entity(uid: UID) -> EntitySave:
	return Global.current_game_save.entities[uid.uid]

func start_game_remote(slot_num: int, custom_mission_id: int = -1):
	Global.ui_root_node.visible = false
	Global.ui_root_node.get_node("StaticBody2D/CollisionPolygon2D").disabled = true
	Global.ui_root_node.get_node("StaticBody2D/CollisionPolygon2D2").disabled = true
	start_game(slot_num, Global.mission_system.default_mission_tree.missions[custom_mission_id] if custom_mission_id != -1 else null)

# Loads a level and then adds it to the Game container.
func start_game(slot_num: int, custom_mission: Mission = null) -> void:
	var level_data := _load_game_save(slot_num)
	
	Global.current_game_slot = slot_num
	Global.current_game_save = level_data
	Global.ui_root_node.get_node("StaticBody2D/CollisionPolygon2D").disabled = true
	Global.ui_root_node.visible = false
	
	Global.print_debug("Game loaded successfuly, printing loaded data.")
	level_data.debug()
	
	if custom_mission:
		Global.current_mission = custom_mission
		load_level(custom_mission.mission_filepath.file, level_data)
	else:
		load_level(default_level.file)

func load_level(level_path: String, save: GameSave = null):
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
	
	game_started.emit(Global.current_game_slot)
	var level_loaded := load(level_path)
	var instantiated = level_loaded.instantiate()
	
	game_container.add_child(instantiated)
	Global.current_mission_node = instantiated
	Global.game_time_system.set_time(0, 0)
	if(level_path!="res://Scenes/TSCN/Levels/Playable/ResearchStation.tscn"):
		Global.brightness_modulate.visible = true
	if !save || Global.is_multiplayer:
		return
	
	for saver in save.node_saves:
		saver.load_node(instantiated)

# Close and save game and exit to menu.
func exit_to_menu() -> void:
	on_exit_to_menu.emit()
	
	# Doesn't need to be put in the ingame debug chat.
	if Global.verbose_debug:
		print("DEBUG: Exit to menu called, printing stack.")
		print_stack()
	
	# Don't save state, because that will be done when the player goes to the research station.
	# In the future there should be a popup warning the player about this.
	# save_state()
	Global.current_game_save = null
	Global.current_game_slot = -1
	Global.ui_root_node.visible = true
	# tf do you mean "???", its a function to open the menu 
	Global.ui_root_node.get_node("MainMenu").visible = true # ???
	Global.ui_root_node.get_node("StaticBody2D/CollisionPolygon2D").disabled = false
	# CARSON ACTUALLY WHAT IS THIS WHY IS THERE TWO
	#Global.ui_root_node.get_node("StaticBody2D/CollisionPolygon2D2").disabled = false
	
	for child in game_container.get_children():
		# BrightnessModulate my goat
		if(child.name!="BrightnessModulate"):
			child.queue_free()
	
	if !ui_root_node_path:
		print("WARNING: SaveLoadFramework contains no UI root node, no menu to exit to.")
		return
	
	var ui_generator: Node = get_node(ui_root_node_path).get_node("UIGenerator")
	
	if !ui_generator:
		print("WARNING: SaveLoadFramework contains no UI generator path, no menu to exit to.")
		return

	ui_generator.toggle_ui()
	
