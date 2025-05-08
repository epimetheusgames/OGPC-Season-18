class_name PressableButtonsPanel
extends PanelContainer

@onready var texts: Array = $MarginContainer/HBoxContainer.get_children()
var buttons: Array[ButtonPress]

func _ready() -> void:
	Global.pressable_buttons_panel = self

func _process(delta: float) -> void:
	for i in range(texts.size()):
		var text: Label = texts[i]
		if i > buttons.size() - 1:
			text.text = ""
			continue
		
		text.text = buttons[i].button + ": " + buttons[i].action + " |"

func remove(action: String):
	for button in buttons:
		if button.action == action:
			buttons.remove_at(buttons.find(button))

func has(action: String) -> bool:
	for button in buttons:
		if button.action == action:
			return true
	return false

class ButtonPress:
	var action: String
	var button: String
	
	static func create(action: String, button: String) -> ButtonPress:
		var out := ButtonPress.new()
		out.action = action
		out.button = button
		return out
