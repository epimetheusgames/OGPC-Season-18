# This code was based on code from the Dunebound codebase.
extends Node

var default_color: Color
var keybind_config := JSON.new()
var keybind_config_data

# Controls the background color 
@export var background := Color("0e0e0e"):
	set(val):
		background = val
		reinitialize_ui()

# Controls the distance between each entry in the keybind menu
@export var keybind_entry_padding: int = 20:
	set(val):
		keybind_entry_padding = val
		reinitialize_ui()

# Controls the distance between each button to change a specific key
@export var keybind_entry_element_padding: int = 10:
	set(val):
		keybind_entry_element_padding = val
		reinitialize_ui()

@export var text_offset_y: int = 0:
	set(val):
		text_offset_y = val
		reinitialize_ui()

@export var button_offset_x: int = 0:
	set(val):
		button_offset_x = val
		reinitialize_ui()

# Controls the location of the first entry
@export var starting_location := Vector2(0,0):
	set(val):
		starting_location = val
		reinitialize_ui()

# Default template button.
@export_node_path("Button") var button_template_path:
	set(val):
		button_template_path = val
		reinitialize_ui()

var button_template: Button
var ready_called := false

func _ready():
	ready_called = true
	reinitialize_ui()
	
func reinitialize_ui():
	if ready_called:
		button_template = get_node(button_template_path)
		default_color = RenderingServer.get_default_clear_color()
		
		# Get string representing a keybinds.json file generated from the actions set in 
		# project settings and parse it into a tree
		keybind_config.parse(json_config_generator())
		keybind_config_data = keybind_config.data
		_clear_ui_elements()
		generate_ui_elements()

# Takes an array of actions, and removes the builtin actions
func remove_stock_keybinds(array: Array) -> Array:
	var values_to_remove := []
	for y in range(array.size()):
		if array[y - 1].begins_with("ui_"):
			values_to_remove.append(y-1)
	
	var return_array := array.duplicate(true)
	for x in range(values_to_remove.size()):
		return_array.pop_front()
		
	return return_array

func get_input_key_names(array: Array) -> Array:
	var return_array = []
	
	if array.size() > 1:
		for x in array.size():
			var keycode := DisplayServer.keyboard_get_keycode_from_physical(array[x].physical_keycode)
			return_array.append(OS.get_keycode_string(keycode))
	else:
		var keycode := DisplayServer.keyboard_get_keycode_from_physical(array[0].physical_keycode)
		return_array.append(OS.get_keycode_string(keycode))
		
	return return_array

# I'm not using a keybind config file because it's easier to just use the built in settings thing to change them
# this function makes it so I can still take advantage of the ease of use of JSON arrays 
# without having to make it harder for teammates.
func json_config_generator() -> String:
	var json_config: String = '{"keybinds":['
	var actions = InputMap.get_actions()
	var usable_actions = remove_stock_keybinds(actions)
	
	#i hope carson is a smart enough person to know how to iterate through arrays properly
	#the size-minus-1 method doesnt work when usable_actions.size is less than 2
	#which means i have to use this functional and readable, yet not very pretty-looking hack
	
	#and thats right carson i used a "hack". before you hop on discord and tell me to get good, please
	#check out the source leaks of literally any triple-A game, and see how severe those hacks are compared to this one
	
	#chances are you arent going to complain and probably dont care that much
	#but look i gotta be ready for anything
	
	#note if your going to remove the hack and replace it with a better solution, please let me know
	#so i can apply it to the rest of the functions in the file that also utilize the hack
	
	# Hi sequoia, I'm not going to remove your hack because I don't really understand the code (;
	# Maybe someday ...
	
	if usable_actions.size() > 1:
		for x in range(usable_actions.size()):
			var keys = InputMap.action_get_events(usable_actions[x])
			var key_strings = get_input_key_names(keys)
			
			json_config += '{"actionName":"' + usable_actions[x] + '","key":['
			 
			for y in keys.size():
				json_config += '"'+ key_strings[y] + '"'
				if keys.size() > 1 && !y == keys.size():
					json_config += ","
				
			json_config += "]}"
		
			if usable_actions.size() > 1 && !x == usable_actions.size():
				json_config = json_config + ","
			
		json_config = json_config + ']}'
		return json_config
	else:
		var keys = InputMap.action_get_events(usable_actions[0])
		
		# Exception handling for no keys to an event
		if len(keys) <= 0:
			print("WARNING: No keys attached to event " + usable_actions[0] + ". This will cause an error ...")
		
		var key_strings = get_input_key_names(keys)
		
		json_config += '{"actionName":"' + usable_actions[0] + '","key":[' 
		
		if keys.size() > 1:
			for y in keys.size()-1:
				json_config += '"' + key_strings[y] + '"'
				if !y == keys.size():
					json_config += ","
		else:
			json_config += '"'+ key_strings[0] + '"'
			
		json_config += "]}]}"
		return json_config

# TODO: This function should be replaced with smoother visuals.
func toggle_ui():
	get_parent().visible = !self.get_parent().visible
	if(get_parent().visible):
		RenderingServer.set_default_clear_color(background)
	else:
		RenderingServer.set_default_clear_color(default_color)

func nodes_from_array(array: Array, caller=self) -> void:
	for x in array.size():
		caller.add_child(array[x])

func _clear_ui_elements() -> void:
	for child in get_children():
		child.queue_free()

func generate_ui_elements() -> void:
	var new_buttons = []
	var new_entries = []
	var last_entry_pos: Vector2 = starting_location - Vector2(keybind_entry_padding, 0)
	
	if keybind_config_data["keybinds"].size() > 1:
		for actionIterator in keybind_config_data["keybinds"].size():
			var new_text = RichTextLabel.new()
			new_text.size = Vector2(100, 50)
			new_text.text = keybind_config_data["keybinds"][actionIterator]["actionName"]
			new_text.position = last_entry_pos + Vector2(0, keybind_entry_element_padding)
			new_entries.append(new_text)
		
			var last_button_pos = new_text.position.x
			for event_iterator in keybind_config_data["keybinds"][actionIterator]["key"].size():
				new_buttons.append(button_template.duplicate())
				new_buttons[-1].text = keybind_config_data["keybinds"][actionIterator]["key"][event_iterator]
				new_buttons[-1].position.y = new_text.position.y
				new_buttons[-1].position.x = last_button_pos + keybind_entry_element_padding + button_offset_x
				new_buttons[-1].keybind_changed.connect(self._on_template_button_keybind_changed)
			
			last_entry_pos = new_text.position
	else:
		var new_text := RichTextLabel.new()
		new_text.size = Vector2(100, 100)
		new_text.text = keybind_config_data["keybinds"][0]["actionName"]
		new_text.position = last_entry_pos
		new_entries.append(new_text)
		
		var last_button_pos = new_text.position.x + new_text.size.y
		
		if keybind_config_data["keybinds"][0]["key"].size() > 1:
			for event_iterator in keybind_config_data["keybinds"][0]["key"].size():
				new_buttons.append(button_template.new())
				new_buttons[event_iterator].text = keybind_config_data["keybinds"][0]["key"]
				new_buttons[event_iterator].position.y = new_text.position.y
				new_buttons[event_iterator].position.x = last_button_pos.x + keybind_entry_element_padding * event_iterator
		else:
			button_template = get_node(button_template_path)
			new_buttons.append(button_template.duplicate())
			new_buttons[0].text = keybind_config_data["keybinds"][0]["key"][0]
			new_buttons[0].position.y = new_text.position.y
			new_buttons[0].position.x = last_button_pos
		
		last_entry_pos = new_text.position
		
	# Add text offset
	for entry in new_entries:
		entry.position.y += text_offset_y
	
	# Add buttons and entries into scene.
	nodes_from_array(new_buttons)
	nodes_from_array(new_entries)

func _on_template_button_keybind_changed() -> void:
	for child in get_children():
		if child is Button:
			child.reset_keybind()
