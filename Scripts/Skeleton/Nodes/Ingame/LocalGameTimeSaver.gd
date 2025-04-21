extends Node


var current_hours: int = 0
var current_minutes: int = 0
var current_day: int = 0
var ready_to_start_updating := false
var total_saved_civillians := 0

func _ready() -> void:
	Global.save_load_framework.save_nodes.connect(_save)
	
	await get_tree().create_timer(0.1).timeout
	
	Global.game_time_system.set_time(current_hours, current_minutes)
	Global.game_time_system._days = current_day
	get_parent().total_saved_civillians = total_saved_civillians
	ready_to_start_updating = true

func _process(_delta: float) -> void:
	if !ready_to_start_updating:
		return
	
	current_hours = Global.game_time_system._hours
	current_minutes = Global.game_time_system._minutes
	current_day = Global.game_time_system._days
	total_saved_civillians = get_parent().total_saved_civillians

func _save() -> void:
	Global.current_game_save.node_saves.append(NodeSaver.create(Global.current_mission_node, self, 
		["current_hours", "current_minutes", "current_day", "total_saved_civillians"]
	))
