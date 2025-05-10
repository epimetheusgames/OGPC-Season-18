class_name IngameDialog
extends PanelContainer

func _ready() -> void:
	Global.ingame_dialog = self

func dialog(message: String) -> void:
	visible = true
	$MarginContainer/VBoxContainer/Label.text = message

func _on_button_button_up() -> void:
	visible = false
