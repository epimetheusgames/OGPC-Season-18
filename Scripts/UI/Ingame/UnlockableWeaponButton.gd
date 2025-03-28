class_name UnlockableWeaponButton
extends PanelContainer

@export var weapon_name: String

@onready var button: Button = $MarginContainer2/UnlockableWeaponButton
@onready var texture_rect: TextureRect = $MarginContainer2/MarginContainer/VBoxContainer/TextureRect

func _ready() -> void:
	$MarginContainer2/MarginContainer/VBoxContainer/Label.text = weapon_name
