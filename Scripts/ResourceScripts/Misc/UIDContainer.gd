# Owned by: carsonetb
@tool
extends Resource
class_name UID


@export var uid: int = -1
var game_load_error: Error

func _init() -> void:
	resource_local_to_scene = true
	
	call_deferred("check_uid")

# This has to be in here because I can't find a way to access the scenetree from inside a resource.
func _save_global_config(content: GlobalSave) -> void:
	var config_file = ConfigFile.new()
	config_file.set_value("Main", "GlobalSave", content)
	config_file.save("user://global")

func _load_global_config() -> GlobalSave:
	var blank_config = ConfigFile.new()
	var slot_path = "user://global"
	
	game_load_error = blank_config.load(slot_path)
	var game_save: GlobalSave = blank_config.get_value("Main", "GlobalSave")
	
	if !game_save:
		print("ERROR: Couldn't load GameSave for whatever reason. Should be an error in the errors tab.")
		return null
	
	return game_save

func check_uid() -> void:
	if uid == -1:
		call_deferred("refresh_uid")

func refresh_uid() -> void:
	var game_save: GlobalSave = _load_global_config()
	
	if !game_save:
		print("ERROR: Can't update UID because game save couldn't load.")
		return
	
	if game_load_error != OK:
		game_save = GlobalSave.new()
	
	game_save.uid_counter += 1
	uid = game_save.uid_counter
	_save_global_config(game_save)
