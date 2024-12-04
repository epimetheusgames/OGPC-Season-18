## Dev panel useful for debugging while the game is running
# Owned by: kaitaobenson

@tool
extends Node

@export var text_box_size: Vector2 = Vector2(300, 50)
@export var button_box_size: Vector2 = Vector2(50, 50)

@onready var text_container: VBoxContainer = $"HBoxContainer/Text"
@onready var button_container: VBoxContainer = $"HBoxContainer/Buttons"

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	
	# Only runs in editor
	var text_h_boxes: Array[Node] = text_container.get_children()
	var button_h_boxes: Array[Node] = button_container.get_children()
	
	for text_h_box in text_h_boxes:
		var text = text_h_box.get_child(0) as RichTextLabel
		if text:
			text.custom_minimum_size = text_box_size
	
	for button_h_box in button_h_boxes:
		var button = button_h_box.get_child(0) as Button
		if button:
			button.custom_minimum_size = button_box_size

func get_pixelization_button() -> CustomCheckbox:
	return $"HBoxContainer/Buttons/HBox1/CustomCheckbox"

func get_quantization_button() -> CustomCheckbox:
	return $"HBoxContainer/Buttons/HBox2/CustomCheckbox"

func get_shadows_button() -> CustomCheckbox:
	return $"HBoxContainer/Buttons/HBox3/CustomCheckbox"
