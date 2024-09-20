# TODO: FIX THIS GOOFY AHH CODE SEQUOIA!!!
# TODO: I LITERALLY CANNOT UNDERSTAND WHAT IS BEING DONE HERE!!!
extends Button


@onready var keybind_text: String = text
var setting_keybind := false
var parse := JSON.new()

signal keybind_changed

func _on_button_up() -> void:
	keybind_changed.emit()
	setting_keybind = true
	text = "Press any button ..."

func reset_keybind() -> void:
	setting_keybind = false
	text = keybind_text

func _input(event) -> void:
	if event is InputEventKey && event.pressed && setting_keybind:
		if event.keycode != KEY_ESCAPE:
			var key_string := DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
			text = OS.get_keycode_string(key_string)
			keybind_text = text
			change_keybind(get_meta("action"), get_meta("key_number"), keybind_text)
		else:
			keybind_changed.emit()
		
		setting_keybind = false

func add_input_action(key:String,actionName:String):
	var keycode_stringconv = OS.find_keycode_from_string(key)
	var new_key:InputEventKey = InputEventKey.new()
	new_key.physical_keycode = keycode_stringconv
	InputMap.add_action(actionName)
	InputMap.action_add_event(actionName,new_key)

func reloadKeybinds():
	var keybindConfig = FileAccess.open("user://keybinds.json",FileAccess.READ)
	var configText = keybindConfig.get_as_text()
	
	var actions = get_parent().get_node("UIGenerator").remove_stock_keybinds(InputMap.get_actions())
	
	parse.parse(configText)
	var parseData = parse.data
	
	for y in parseData["keybinds"].size():
		for x in parseData["keybinds"][y]["key"].size():
			add_input_action(parseData["keybinds"][y]["key"][x],parseData["keybinds"][y]["actionName"])
			
	keybindConfig.close()
	
#key number represents the index of the key in the action, if in an action has multiple keys
#like for example up arrow and space for jump
# Returns if the function was successful ... probably not neccesary if we have the print statement?
func change_keybind(action_name: String, key_number: int, new_key: String) -> bool:
	#buffer_parse holds the json object that will hold the updated keybinds.json
	var buffer_parse:JSON = JSON.new()
	var raw_json := FileAccess.open("user://keybinds.json",FileAccess.READ)
	var json_text = raw_json.get_as_text()
	buffer_parse.parse(json_text)
	
	var json_data = buffer_parse.data
	json_text.close()
	
	# Attempt to find the index of the named action in the keybinds array
	var found_action_number := -1
	for i in range(json_data["keybinds"].size()):
		
		if json_data["keybinds"][i]["actionName"] == action_name:
			found_action_number = i
			break
			
	#the action that this function was called to change doesnt exist, print out to avoid bugs
	if found_action_number == -1:
		print("WARNING: Nonexistant action passed to function change_keybind, this WILL cause errors.")
		return false
		
	# That hack again!
	if key_number > json_data["keybinds"][found_action_number]["key"].size():
		json_data["keybinds"][found_action_number]["key"][0] = new_key
	else:
		json_data["keybinds"][found_action_number]["key"][key_number] = new_key
	
	# Store data to file.
	raw_json = FileAccess.open("user://keybinds.json", FileAccess.WRITE)
	raw_json.store_string(buffer_parse.stringify(json_data, "\t"))
	raw_json.close()
	
	get_parent().reinitialize_ui()
	
	return true
