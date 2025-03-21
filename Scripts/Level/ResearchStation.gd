class_name ResearchStation
extends Node2D

@export var position_node: Node2D
@export var follower_spawn_node: Node2D
@export var follower: PackedScene

func _ready() -> void:
	Global.research_station = self
	Global.game_time_system.day_ended.connect(_spawn)

func _spawn() -> void:
	Global.print_debug("Spawned new follower when day ended.")
	follower_spawn_node.add_child(follower.instantiate())
