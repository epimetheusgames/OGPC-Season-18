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
	for i in range(icons.size()):
		buttons[i].button.button_up.connect(_button_up.bind(icons[i].name))
		var unlocked: bool = Global.player.diver_combat.unlocked_weapons.get("has_" + icons[i].name)
		if unlocked:
			buttons[i].texture_rect.texture = icons[i].unlocked_icon
		else:
			buttons[i].texture_rect.texture = icons[i].locked_icon

func _get_index_by_name(button_name: String) -> int:
	for i in range(icons.size()):
		if icons[i].name == button_name:
			print(icons[i].name)
			return i
	return -1

func _button_up(button_name: String) -> void:
	selected_icon = icons[_get_index_by_name(button_name)]

func _on_secondary_button_button_up() -> void:
	if !selected_icon || primary_weapon == selected_icon.name:
		return
	secondary_weapon = selected_icon.name
	secondary_button.text = selected_icon.formatted_name
	if Global.player.diver_combat.secondary_weapon:
		Global.player.diver_combat.secondary_weapon.enabled = false
	Global.player.diver_combat.secondary_weapon = Global.player.diver_combat.instantiated_weapons[secondary_weapon]
	selected_icon = null

func _on_primary_button_button_up() -> void:
	if !selected_icon || secondary_weapon == selected_icon.name:
		return
	primary_weapon = selected_icon.name
	primary_button.text = selected_icon.formatted_name
	if Global.player.diver_combat.primary_weapon:
		Global.player.diver_combat.primary_weapon.enabled = false
	Global.player.diver_combat.primary_weapon = Global.player.diver_combat.instantiated_weapons[primary_weapon]
	selected_icon = null
