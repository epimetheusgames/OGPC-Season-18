# Owned by: carsonetb
extends GutTest

var slf: SaveLoadFramework

func before_each():
	slf = SaveLoadFramework.new()

func test_save():
	var test_config := ConfigFile.new()
	test_config.set_value("A", "B", 5)
	slf._save_config_file(test_config, 6)
	var saved_config = ConfigFile.new()
	saved_config.load("user://slot_6")
	assert_eq(saved_config.get_value("A", "B"), 5)
	
	var loaded_config = slf._load_config_file(6)[0]
	assert_eq(loaded_config.get_value("A", "B"), 5)
	
	slf.save_encrypted = true
	slf._save_config_file(test_config, 6)
	saved_config = ConfigFile.new()
	saved_config.load_encrypted_pass("user://slot_6", Global.get_slot_password(6))
	assert_eq(saved_config.get_value("A", "B"), 5)
	
	loaded_config = slf._load_config_file(6)[0]
	assert_eq(loaded_config.get_value("A", "B"), 5)

func test_save_global():
	var config := slf._load_global_config()
	slf._save_global_config(config)
	var new_config := slf._load_global_config()
	assert_eq(config.uid_counter, new_config.uid_counter)

func test_save_game():
	var game_save = GameSave.new()
	game_save.slot = 6
	slf._save_game_save(game_save, 6)
	
	var saved_config = ConfigFile.new()
	saved_config.load("user://slot_6")
	assert_eq(saved_config.get_value("Main", "GameSave").slot, 6)
	
	var saved_game_save = slf._load_game_save(6)
	assert_eq(saved_game_save.slot, 6)

func test_load_level():
	var game_container := Node.new()
	slf.game_container = game_container
	slf.load_level("res://Scenes/TSCN/Levels/Missions/Mission1.tscn")
	assert_eq(len(game_container.get_children()), 1)
	
	var test_exit_game_save = GameSave.new()
	test_exit_game_save.slot = 6
	Global.current_game_save = test_exit_game_save
	slf.exit_to_menu()
	var loaded_save := slf._load_game_save(6)
	assert_eq(game_container.get_children()[0].is_queued_for_deletion(), true)
	assert_eq(loaded_save.slot, 6)
