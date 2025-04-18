class_name UnlockableItemButton
extends PanelContainer

@export var item_name: String

@onready var button: Button = $MarginContainer2/UnlockableWeaponButton
@onready var texture_rect: TextureRect = $MarginContainer2/MarginContainer/VBoxContainer/TextureRect
@export var texture: Texture2D

func _ready() -> void:
	$MarginContainer2/MarginContainer/VBoxContainer/Label.text = item_name
	texture_rect.texture = texture
