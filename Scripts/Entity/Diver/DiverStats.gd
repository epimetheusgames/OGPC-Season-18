class_name DiverStats
extends Node2D

var max_health: float = health
var health: float = 100
var oxygen_percentage: float = 100
var oxygen_loss: float
var completion_areas_entered: Array[CompletionArea]
var current_money: int = 0
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var diver: Diver = get_parent()

func _ready() -> void:
	while true:
		await get_tree().create_timer(0.8).timeout
		if oxygen_percentage <= 0:
			hurtbox.damage(5, null)

func _process(delta: float) -> void:
	if Global.godot_steam_abstraction && Global.is_multiplayer && !diver._is_node_owner():
		return
	
	oxygen_percentage -= oxygen_loss * delta * 60
	if diver.get_state() == Diver.DiverState.IN_GRAVITY_AREA:
		oxygen_percentage = 100
	if abs(diver.global_position.y) < 80:
		oxygen_percentage = 100
	
	health = hurtbox.health
	
	if Global.godot_steam_abstraction:
		Global.godot_steam_abstraction.sync_var(self, "health")
		Global.godot_steam_abstraction.sync_var(self, "oxygen_percentage")

func _on_general_detection_box_area_entered(area: Area2D) -> void:
	if area is CompletionArea:
		completion_areas_entered.append(area)

func _on_general_detection_box_area_exited(area: Area2D) -> void:
	if area is CompletionArea:
		completion_areas_entered.remove_at(completion_areas_entered.find(area))

func get_health() -> float:
	return health

func get_max_health() -> float:
	return max_health
