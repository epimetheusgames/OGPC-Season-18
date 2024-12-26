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
	add_weapon("pistol")
	
	set_weapon("pistol")
	#set_weapon("speargun")
	#print_tree_pretty()

var a: int = 0  # I'll remove this later

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("swap"):
		if a == 0:
			set_weapon("pistol")
			a = 1
		else:
			set_weapon("speargun")
			a = 0
		
		print(selected_weapon.name)
	
	if Input.is_action_just_pressed("attack"):
		selected_weapon.attack()


# current_weapons (setters / getters)
func add_weapon(weapon_name: String) -> void:
	if current_weapons.has(weapon_name):
		return
	
	var weapon: PackedScene = all_weapons.get(weapon_name)
	if weapon == null:
		printerr("Weapon not found")
		return
	
	var new_weapon: Weapon = weapon.instantiate()
	new_weapon.diver = diver
	
	current_weapons[weapon_name] = new_weapon
	add_child(new_weapon)

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
	weapon.visible = true
	selected_weapon = weapon

func disable_all() -> void:
	for weapon: Weapon in current_weapons.values():
		weapon.visible = false
