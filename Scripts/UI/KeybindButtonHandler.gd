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
		
