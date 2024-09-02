extends Button

@onready var keybind_text:String = text
var setting_keybind:bool = false
var Parse:JSON = JSON.new()

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
			changeKeybind(self.get_meta("action"),self.get_meta("key_number"),keybind_text)
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
	
	Parse.parse(configText)
	var parseData = Parse.data
	
	for y in parseData["keybinds"].size():
		for x in parseData["keybinds"][y]["key"].size():
			print(InputMap.get_actions())
			add_input_action(parseData["keybinds"][y]["key"][x],parseData["keybinds"][y]["actionName"])
			
	keybindConfig.close()
	
#key number represents the index of the key in the action, if in an action has multiple keys
#like for example up arrow and space for jump
func changeKeybind(actionName:String,keyNumber:int,newKey:String)->bool:
	#buffer_parse holds the json object that will hold the updated keybinds.json
	var buffer_parse:JSON = JSON.new()
	var lerawjson = FileAccess.open("user://keybinds.json",FileAccess.READ)
	var lejson = lerawjson.get_as_text()
	buffer_parse.parse(lejson)
	
	var leJsonBuffer = buffer_parse.data
	lerawjson.close()
	
	#attempt to find the index of the named action in the keybinds[] array
	var foundActionNumber = -1
	for bhhbj in leJsonBuffer["keybinds"].size():
		
		if(leJsonBuffer["keybinds"][bhhbj]["actionName"]==actionName):
			foundActionNumber = bhhbj
			break
			
	#the action that this function was called to change doesnt exist, print out to avoid bugs
	if(foundActionNumber == -1):
		print("change_keybind was  just passed a nonexistent action, something is likely wrong")
		return false
		
	#no matter how many times i write a fix, this bug always comes back somehow
	#update: for anyone who isnt me and doesnt remember what that comment was referring to
	#the code below basically just does the same exact thing as the "hack" in UiGenerator.gd
	if(keyNumber>leJsonBuffer["keybinds"][foundActionNumber]["key"].size()):
		leJsonBuffer["keybinds"][foundActionNumber]["key"][0] = newKey
	else:
		leJsonBuffer["keybinds"][foundActionNumber]["key"][keyNumber] = newKey
		
	lerawjson = FileAccess.open("user://keybinds.json",FileAccess.WRITE)
	lerawjson.store_string(buffer_parse.stringify(leJsonBuffer,"\t"))
	lerawjson.close()
	get_parent().reinitialize_ui()
	
	return true
