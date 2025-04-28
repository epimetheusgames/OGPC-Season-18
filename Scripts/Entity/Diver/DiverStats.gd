class_name DiverStats
extends Node2D

const max_oxygen: float = 100
var oxygen: float = max_oxygen

var oxygen_loss: float = 0.01
var boost_oxygen_loss: float = 0.05

var current_money: int = 0

@onready var hurtbox: Hurtbox = $Hurtbox
@onready var diver: Diver = get_parent()


func _process(delta: float) -> void:
	if Global.godot_steam_abstraction && Global.is_multiplayer && !diver._is_node_owner():
		return
	
	if diver.get_state() == Diver.DiverState.IN_GRAVITY_AREA:
		oxygen = 100
	
	if diver.diver_movement.is_boosting:
		oxygen -= boost_oxygen_loss * delta * 60
	else:
		oxygen -= oxygen_loss * delta * 60
	
	
	if Global.godot_steam_abstraction:
		Global.godot_steam_abstraction.sync_var(self, "health")
		Global.godot_steam_abstraction.sync_var(self, "oxygen")


func get_health() -> float:
	return hurtbox.health

func get_max_health() -> float:
	return hurtbox.max_health
