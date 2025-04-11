class_name UnlockTerminal
extends Node2D

@export var icons: Array[WeaponIcon]
@export var buttons: Array[UnlockableWeaponButton]
@export var item_buttons: Array[UnlockableItemButton]
@export var items: Array[PackedScene]
@export var primary_button: Button
@export var secondary_button: Button

var selected_icon: WeaponIcon = null;
var primary_weapon: String
var secondary_weapon: String
var actual_items: Array[InventoryItem]

@onready var weapon_unlock_menu: VBoxContainer = $SubViewportContainer/SubViewport/WeaponUnlock
@onready var item_unlock_menu: VBoxContainer = $SubViewportContainer/SubViewport/ItemUnlock
@onready var main_menu: MarginContainer = $SubViewportContainer/SubViewport/MainMenu

func _ready() -> void:
	Global.save_load_framework.save_nodes.connect(_save)
	
	for i in range(icons.size()):
		buttons[i].button.button_up.connect(_button_up.bind(icons[i].name))
		var unlocked: bool = Global.player.diver_combat.unlocked_weapons.get("has_" + icons[i].name)
		if unlocked:
			buttons[i].texture_rect.texture = icons[i].unlocked_icon
		else:
			buttons[i].texture_rect.texture = icons[i].locked_icon
	
	for item in items:
		var scene: BaseItem = item.instantiate()
		actual_items.append(scene.generate_inventory_item())
		scene.free()
	
	for i in range(actual_items.size()):
		item_buttons[i].button.button_up.connect(_item_button_up.bind(actual_items[i].name))
	
	await get_tree().create_timer(0.1).timeout
	
	if primary_weapon:
		Global.player.diver_combat.primary_weapon = Global.player.diver_combat.instantiated_weapons[primary_weapon]
	if secondary_weapon:
		Global.player.diver_combat.secondary_weapon = Global.player.diver_combat.instantiated_weapons[secondary_weapon]

func _process(delta: float) -> void:
	for i in range(icons.size()):
		buttons[i].button.disabled = Global.player.diver_stats.current_money < icons[i].cost && \
									 !Global.player.diver_combat.unlocked_weapons.get("has_" + icons[i].name)
	
	for i in range(actual_items.size()):
		item_buttons[i].button.disabled = Global.player.diver_stats.current_money < actual_items[i].cost

func _save() -> void:
	Global.current_game_save.node_saves.append(NodeSaver.create(Global.current_mission_node, self,
		[
			"primary_weapon",
			"secondary_weapon",
		],
		{
			get_path_to(primary_button): ["text", "icon"],
			get_path_to(secondary_button): ["text", "icon"]
		},
		true
	))

func _get_index_by_name(button_name: String) -> int:
	for i in range(icons.size()):
		if icons[i].name == button_name:
			return i
	return -1

func _button_up(button_name: String) -> void:
	var clicked_icon := icons[_get_index_by_name(button_name)]
	var unlocked_weapons := Global.player.diver_combat.unlocked_weapons
	
	if unlocked_weapons.get("has_" + clicked_icon.name):
		selected_icon = clicked_icon
		return
	
	if Global.player.diver_stats.current_money >= clicked_icon.cost:
		unlocked_weapons.set("has_" + clicked_icon.name, true)
		Global.player.diver_stats.current_money -= clicked_icon.cost
		selected_icon = clicked_icon

func _item_button_up(button_name: String) -> void:
	var item: InventoryItem
	for _item in actual_items:
		if _item.name == button_name:
			item = _item
			break
	
	if Global.player.diver_stats.current_money < item.cost:
		return
	Global.player.diver_stats.current_money -= item.cost
	Global.player.diver_inventory.__collect_item((load(item.scene.file) as PackedScene).instantiate())

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
	var diver_primary_weapon_obj := Global.player.diver_combat.primary_weapon
	if !selected_icon || secondary_weapon == selected_icon.name:
		return
	primary_weapon = selected_icon.name
	primary_button.text = selected_icon.formatted_name
	if diver_primary_weapon_obj:
		diver_primary_weapon_obj.enabled = false
	diver_primary_weapon_obj = Global.player.diver_combat.instantiated_weapons[primary_weapon]
	selected_icon = null

func _on_back_button_button_up() -> void:
	weapon_unlock_menu.visible = false
	item_unlock_menu.visible = false
	main_menu.visible = true

func _on_weapons_button_button_up() -> void:
	main_menu.visible = false
	weapon_unlock_menu.visible = true

func _on_items_button_button_up() -> void:
	main_menu.visible = false
	item_unlock_menu.visible = true
