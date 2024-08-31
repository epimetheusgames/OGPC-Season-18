extends Button

@onready var keybind_text := text
var setting_keybind := false

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
		else:
			keybind_changed.emit()
		
		setting_keybind = false
		
func changeKeybind(actionName:String,keybindNumber:int,newKey:String)->bool:
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
			
	#the action that this function was called to change doesnt exist, print out to avoid errors
	if(foundActionNumber == -1):
		print("change_keybind was  just passed a nonexistent action, something is likely wrong")
		return false
		
	#no matter how many times i write a fix, this bug always comes back somehow
	#update: for anyone who isnt me and doesnt remember what that comment was referring to
	#the code below basically just does the same exact thing as the "hack" in UiGenerator.gd
	if(keybindNumber>leJsonBuffer["keybinds"][foundActionNumber]["key"].size()):
		leJsonBuffer["keybinds"][foundActionNumber]["key"][0] = newKey
	else:
		leJsonBuffer["keybinds"][foundActionNumber]["key"][keybindNumber] = newKey
		
	lerawjson = FileAccess.open("user://keybinds.json",FileAccess.WRITE)
	lerawjson.store_string(buffer_parse.stringify(leJsonBuffer,"\t"))
	lerawjson.close()
	get_parent().get_node("UIGenerator").reinitialize_ui()
	return true
