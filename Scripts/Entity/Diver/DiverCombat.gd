## Diver combat system.
# Owned by: kaitaobenson

class_name DiverCombat
extends Node2D

@export var speargun: PackedScene
@export var knife: PackedScene
@export var pistol: PackedScene

@onready var all_weapons: Dictionary = {
	"speargun" : speargun,
	"knife" : knife,
	"pistol" : pistol,
}

@onready var diver: Diver = get_parent()

# Loaded weapons in inventory (Optimize for switching weapons)
var current_weapons: Dictionary

var selected_weapon: Weapon

func _ready():
	add_weapon("speargun")
	set_weapon("speargun")


# current_weapons (setters / getters)
func add_weapon(weapon_name: String) -> void:
	if current_weapons.has(weapon_name):
		return
	
	var weapon: PackedScene = all_weapons.get(weapon_name, null)
	if weapon == null:
		printerr("Weapon not found")
		return
	
	current_weapons[weapon_name] = weapon.instantiate()

func remove_weapon(weapon_name: String) -> void:
	var result: bool = current_weapons.erase(weapon_name)
	if result == false:
		printerr("Weapon not found")

func remove_all_weapons() -> void:
	current_weapons.clear()


# selected_weapon (setters / getters)
func set_weapon(weapon_name: String) -> void:
	var weapon: Weapon = current_weapons.get(weapon_name)
	
	if weapon == null:
		printerr("Weapon not found")
		return
	if weapon == selected_weapon:
		return
	
	disable_all()
	weapon.enabled = true

func disable_all() -> void:
	for weapon: Weapon in current_weapons:
		weapon.enabled = false
