# WARNING
# THIS FILE IS DEPRECATED AND SHOULD NOT
# BE USED IN THE ACTUAL GAME.


#i know this code doesnt align with all the fancy formatting standards yall set
#i will make sure to make all my code formatted well later, probably when the scholyear actually starts and development
#picks up speed
extends Node
var buttonTemplate
var default_color

var viewportRect

var keybindConfig:JSON = JSON.new()
var keybindConfigData

#this variable controls the background color 
const background = Color("0e0e0e")

#this variable controls the distance between each entry in the keybind menu
const keybindEntryPadding:int = 20

#this variable controls the distance between each button to change a specific key
const keybindEntryElementPadding:int = 10

#this variable controls the location of the first entry
const startingLocation = Vector2(0,0)

#this variable was originally designed to determine whether or not the keybinds.json file has been read and turned into godot actions,
#but keybinds.json isnt used anymore so this shouldnt need to ever be changed
var actionsLoaded:bool = false

#takes an array of actions, and removes the builtin actions
func remove_stock_keybinds(array:Array)->Array:
	var values_to_remove = []
	for y in array.size():
		if(array[y-1].begins_with("ui_")):
			values_to_remove.append(y-1)
	
	var returnArray = array.duplicate(true)
	for x in values_to_remove.size():
		returnArray.pop_front()
		
	return returnArray
func get_inputeventkey_names(array:Array)->Array:
	
	var returnArray = []
	
	if(array.size()>1):
		
		for x in array.size():
			returnArray.append(OS.get_keycode_string(DisplayServer.keyboard_get_keycode_from_physical(array[x].physical_keycode)))
			
	else:
		
		returnArray.append(OS.get_keycode_string(DisplayServer.keyboard_get_keycode_from_physical(array[0].physical_keycode)))
		
	return returnArray

#im not using a keybind config file because its easier to just use the built in settings thing to change them
#this function makes it so i can still take advantage of the ease of use of json arrays 
#witout having to make it harder for teammates
func json_config_generator()->String:
	var json_config:String = '{"keybinds":['
	var actions = InputMap.get_actions()
	var usable_actions = remove_stock_keybinds(actions)
	
	print("breakpoint checkpoint")
	
	#i hope carson is a smart enough person to know how to iterate through arrays properly
	#the size-minus-1 method doesnt work when usable_actions.size is less than 2
	#which means i have to use this functional and readable, yet not very pretty-looking hack
	
	#and thats right carson i used a "hack". before you hop on discord and tell me to get good, please
	#check out the source leaks of literally any triple-A game, and see how severe those hacks are compared to this one
	
	#chances are you arent going to complain and probably dont care that much
	#but look i gotta be ready for anything
	
	#note if your going to remove the hack and replace it with a better solution, please let me know
	#so i can apply it to the rest of the functions in the file that also utilize the hack
	if usable_actions.size()>1:
		
		for x in usable_actions.size()-1:
			
			var keys = InputMap.action_get_events(usable_actions[x])
			var key_strings = get_inputeventkey_names(keys)
			
			json_config = json_config + '{"actionName":"' + usable_actions[x] + '","key":['
			 
			for y in keys.size()-1:
			
				json_config = json_config +'"'+ key_strings[y] + '"'
				if(keys.size()>1 and not y==keys.size()):
					json_config = json_config + ","
				
			json_config = json_config + "]}"
		
			if(usable_actions.size()>1 and not x==usable_actions.size()):
				json_config = json_config + ","
			
		json_config = json_config + ']}'
		return json_config
	else:
		var keys = InputMap.action_get_events(usable_actions[0])
		var key_strings = get_inputeventkey_names(keys)
		json_config = json_config + '{"actionName":"' + usable_actions[0] + '","key":[' 
		
		if(keys.size()>1):
			for y in keys.size()-1:
				
				json_config = json_config +'"'+ key_strings[y] + '"'
				if(not y==keys.size()):
					json_config = json_config + ","
		else:
			
			json_config = json_config +'"'+ key_strings[0] + '"'
			
		json_config = json_config + "]}]}"
		return json_config
func toggle_ui():
	self.get_parent().visible = !self.get_parent().visible
	if(get_parent().visible):
		RenderingServer.set_default_clear_color(background)
	else:
		RenderingServer.set_default_clear_color(default_color)
func _ready():
	buttonTemplate = get_parent().get_node("TemplateButton")
	default_color = RenderingServer.get_default_clear_color()
	
	#get string representing a keybinds.json file generated from the actions set in project settings and parse it into a tree
	print(json_config_generator())
	keybindConfig.parse(json_config_generator())
	
	keybindConfigData = keybindConfig.data
	generate_UI_elements()
func nodes_from_array(array:Array,caller=self)->void:
	for x in array.size():
		caller.add_child(array[x])
func xOffsetVector2(vector:Vector2,offset:int)->Vector2:
	var newVector = vector
	newVector.x += offset
	return newVector
func generate_UI_elements()->void:
	var newButtons = []
	var newEntries = []
	var lastEntryPos:Vector2=xOffsetVector2(startingLocation,-keybindEntryPadding)
	if(keybindConfigData["keybinds"].size()>1):
		
		for actionIterator in keybindConfigData["keybinds"].size():
			var newText = RichTextLabel.new()
			newText.text = keybindConfigData["keybinds"][actionIterator]["actionName"]
	
			newText.position = lastEntryPos
		
			var lastButtonPos = newText.position.x
			for eventIterator in keybindConfigData["keybinds"][actionIterator]["key"].size():
				
				newButtons.append(buttonTemplate.duplicate())
				newButtons[eventIterator].text = keybindConfigData["keybinds"][actionIterator]["key"]
				newButtons[eventIterator].position.y = newText.position.y
				newButtons[eventIterator].position.x = lastButtonPos+keybindEntryElementPadding
			
			lastEntryPos =  newText.position
	else:
		var newText = RichTextLabel.new()
		
		newText.text = keybindConfigData["keybinds"][0]["actionName"]
		newText.position = lastEntryPos
		newEntries.append(newText)
		
		var lastButtonPos = newText.position.x
		
		if(keybindConfigData["keybinds"][0]["key"].size()>1):
			for eventIterator in keybindConfigData["keybinds"][0]["key"].size():
				newButtons.append(buttonTemplate.new())
				newButtons[eventIterator].text = keybindConfigData["keybinds"][0]["key"]
				newButtons[eventIterator].position.y = newText.position.y
				newButtons[eventIterator].position.x = lastButtonPos.x+(keybindEntryElementPadding*eventIterator)
		else:
			newButtons.append(buttonTemplate.new())
			newButtons[0].text = keybindConfigData["keybinds"][0]["key"][0]
			newButtons[0].position.y = newText.position.y
			newButtons[0].position.x = lastButtonPos
		lastEntryPos =  newText.position
	#stupid functions below ust doesnt run il fix it when im not on a plane 
	nodes_from_array(newButtons)
	nodes_from_array(newEntries)
func _process(delta):
	pass
