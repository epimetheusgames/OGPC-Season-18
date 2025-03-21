class_name FollowerSpawner
extends Node2D

@export var follower: PackedScene

func _ready() -> void:
	Global.game_time_system.day_ended.connect(_spawn)

func _spawn() -> void:
	Global.print_debug("Spawned new follower when day ended.")
	add_child(follower.instantiate())
