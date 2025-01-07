class_name MissionSystem
extends Node


@export var default_mission_tree: MissionTree
var mission_tree: MissionTreeProgress
var slot: int = -1

func _ready() -> void:
	Global.mission_system = self
	Global.save_load_framework.game_started.connect(_initialize)

func _initialize(slot_num: int) -> void:
	slot = slot_num
	mission_tree = Global.current_game_save.unlocked_mission_tree

func complete_mission(mission: Mission) -> void:
	mission_tree.complete_mission(mission)
	Global.current_game_save.unlocked_mission_tree = mission_tree

func restart_mission() -> void:
	Global.save_load_framework.exit_to_menu()
	Global.save_load_framework.start_game(Global.current_game_slot, Global.current_mission)
