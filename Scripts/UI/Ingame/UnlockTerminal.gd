class_name UnlockTerminal
extends Node2D

@export var icons: Array[WeaponIcon]
@export var buttons: Array[UnlockableWeaponButton]
@export var primary_button: Button
@export var secondary_button: Button

var selected_icon: WeaponIcon = null;
var primary_weapon: String
var secondary_weapon: String

func _ready() -> void:
	for i in range(icons.size() - 1):
		buttons[i].button.button_up.connect(_button_up.bind(buttons[i].name))
		var unlocked: bool = Global.player.diver_combat.unlocked_weapons.get("has_" + icons[i].name)
		if unlocked:
			buttons[i].texture_rect.texture = icons[i].unlocked_icon
		else:
			buttons[i].texture_rect.texture = icons[i].locked_icon

func _get_index_by_name(button_name: String) -> int:
	for i in range(icons.size() - 1):
		if icons[i].name == button_name:
			return i
	return -1

func _button_up(button_name: String) -> void:
	selected_icon = icons[_get_index_by_name(button_name)]

func _on_secondary_button_button_up() -> void:
	if !selected_icon:
		return
	secondary_weapon = selected_icon.name
	secondary_button.text = secondary_weapon
	selected_icon = null

func _on_primary_button_button_up() -> void:
	if !selected_icon:
		return
	primary_weapon = selected_icon.name
	primary_button.text = primary_weapon
	selected_icon = null
