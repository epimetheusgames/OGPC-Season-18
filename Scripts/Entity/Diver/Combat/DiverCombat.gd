## Diver combat system.
# Owned by: kaitaobenson

class_name DiverCombat
extends Node2D

@export var speargun: PackedScene
@export var knife: PackedScene
@export var pistol: PackedScene

@onready var all_weapons: Dictionary[String, PackedScene] = {
	"speargun" : speargun,
	"knife" : knife,
	"pistol" : pistol,
}
@onready var diver: Diver = get_parent()
@onready var reload_bar: TextureProgressBar = $"ReloadBar"

# Loaded weapons in inventory (Optimize for switching weapons)
var instantiated_weapons: Dictionary[String, Weapon]
var primary_weapon: Weapon
var secondary_weapon: Weapon
var selected_weapon: Weapon
var unlocked_weapons: PlayerUnlockedWeapons

func _ready():
	if !unlocked_weapons:
		unlocked_weapons = PlayerUnlockedWeapons.new()
	
	for key in all_weapons.keys():
		var new_weapon: Weapon = all_weapons[key].instantiate()
		instantiated_weapons[key] = new_weapon
		add_child(new_weapon)
	
	for child in get_children():
		if child is Weapon:
			child.enabled = false

func _process(_delta: float) -> void:
	for weapon in get_children():
		if weapon is Weapon && weapon.visible && !weapon == selected_weapon:
			weapon.enabled = false
	
	if diver.get_state() == Diver.DiverState.IN_GRAVITY_AREA:
		visible = false
	else:
		visible = true
	
	if Global.godot_steam_abstraction && Global.is_multiplayer && !diver._is_node_owner():
		return
	
	if diver.diver_movement.is_in_gravity_area:
		return
	
	if Input.is_action_just_pressed("swap") && primary_weapon && secondary_weapon:
		if primary_weapon.enabled:
			primary_weapon.enabled = false
			secondary_weapon.enabled = true
			selected_weapon = secondary_weapon
		elif secondary_weapon && secondary_weapon.enabled:
			secondary_weapon.enabled = false
			primary_weapon.enabled = true
			selected_weapon = primary_weapon
		else:
			primary_weapon.enabled = true
			selected_weapon = primary_weapon
	elif Input.is_action_just_pressed("swap") && primary_weapon && !primary_weapon.enabled:
		primary_weapon.enabled = true
		selected_weapon = primary_weapon
	
	if !selected_weapon:
		return
	
	if Input.is_action_just_pressed("attack"):
		selected_weapon.attack()
	
	if Input.is_action_pressed("aim") && selected_weapon is Gun:
		selected_weapon = selected_weapon as Gun
		selected_weapon.gun_state = Gun.GunState.AIMING
	elif selected_weapon is Gun:
		selected_weapon.gun_state = Gun.GunState.HOLDING
	
	if selected_weapon.use_hand1:
		var new_hand_pos: Vector2 = selected_weapon.get_hand1_pos()
		diver.diver_animation.set_hand1_position(new_hand_pos)
	if selected_weapon.use_hand2:
		var new_hand_pos: Vector2 = selected_weapon.get_hand2_pos()
		diver.diver_animation.set_hand2_position(new_hand_pos)

# Reload bar
func set_reload_bar(val: float) -> void:
	if val == 0:
		reload_bar.visible = false
	else:
		reload_bar.visible = true
		reload_bar.value = val
