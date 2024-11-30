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
	
	var loaded_config = slf._load_config_file(6)
	assert_eq(loaded_config.get_value("A", "B"), 5)
	
	slf.save_encrypted = true
	slf._save_config_file(test_config, 6)
	saved_config = ConfigFile.new()
	saved_config.load_encrypted_pass("user://slot_6", Global.get_slot_password(6))
	assert_eq(saved_config.get_value("A", "B"), 5)
	
	loaded_config = slf._load_config_file(6)
	assert_eq(loaded_config.get_value("A", "B"), 5)

func test_save_entity():
	var test_entity_save = EntitySave.new()
	test_entity_save.position = Vector2(5, 5)
	test_entity_save.velocity = Vector2(-1, 0)
	var test_uid = UID.new()
	slf._save_entity(6, test_uid, test_entity_save)
	
	var saved_config = ConfigFile.new()
	saved_config.load("user://slot_6")
	assert_eq(saved_config.get_value("Entities", str(test_uid.uid)).position, test_entity_save.position)
	assert_eq(saved_config.get_value("Entities", str(test_uid.uid)).velocity, test_entity_save.velocity)
	
	var loaded_entity = slf._load_entity(6, test_uid)
	assert_eq(loaded_entity.position, test_entity_save.position)
	assert_eq(loaded_entity.velocity, test_entity_save.velocity)

func test_save_global():
	var config := slf._load_global_config()
	slf._save_global_config(config)
	var new_config := slf._load_global_config()
	assert_eq(config.uid_counter, new_config.uid_counter)

func test_save_game():
	var game_save = GameSave.new()
	game_save.slot = 6
	game_save.level = 5
	slf._save_game_save(game_save, 6)
	
	var saved_config = ConfigFile.new()
	saved_config.load("user://slot_6")
	assert_eq(saved_config.get_value("Main", "GameSave").slot, 6)
	assert_eq(saved_config.get_value("Main", "GameSave").level, 5)
	
	var saved_game_save = slf._load_game_save(6)
	assert_eq(saved_game_save.slot, 6)
	assert_eq(saved_game_save.level, 5)
