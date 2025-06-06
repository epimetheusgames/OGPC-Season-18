class_name ResearchStation
extends Node2D

@onready var position_node: Node2D = $"ResearchStationPosition"
@onready var follower_spawn_node: Node2D = $"FollowerSpawnPosition"
@onready var black_background: ColorRect = $"ColorRect"
@onready var research_station_area: Area2D = $"ResearchStationArea"
@onready var gravity_area: Area2D = $"GravityArea"
@onready var exterior_polygon: Polygon2D = $"Exterior"

@export var parallax_bubbles: ParallaxBackground
@export var follower: PackedScene
@export var unlock_terminal: UnlockTerminal

var player_in_area := true

signal follower_spawned(spawn_position: Vector2)

func _save() -> void:
	Global.current_game_save.node_saves.append(
		NodeSaver.create(Global.current_mission_node, self, ["player_in_area"])
	)

func _ready() -> void:
	Global.save_load_framework.save_nodes.connect(_save)
	Global.research_station = self
	Global.game_time_system.day_ended.connect(_spawn)

	if black_background:
		black_background.visible = true
		black_background.modulate.a = 0
	else:
		Global.print_error("Research station has no aesthetic black background.", Util.ErrorType.WARNING)
	
	if research_station_area:
		research_station_area.area_entered.connect(_area_entered)
		research_station_area.area_exited.connect(_area_exited)
	else:
		Global.print_error("Research station has no area to detect player.", Util.ErrorType.WARNING)
	
	if gravity_area:
		gravity_area.area_exited.connect(_gravity_area_exited)
	else:
		Global.print_error("Research station has no gravity area.", Util.ErrorType.WARNING)

	if exterior_polygon:
		exterior_polygon.visible = true
	else:
		Global.print_error("Research station has no exterior polygon.", Util.ErrorType.WARNING)
	
	if !parallax_bubbles:
		Global.print_error("Research station has no parallax bubbles.", Util.ErrorType.WARNING)

func _process(_delta: float) -> void:
	if !black_background || !exterior_polygon || !parallax_bubbles:
		return
	
	if player_in_area && black_background.modulate.a < 1:
		black_background.modulate.a = 1
		exterior_polygon.modulate.a = 0
		parallax_bubbles.visible = false
	elif !player_in_area && black_background.modulate.a > 0:
		black_background.modulate.a = 0 
		exterior_polygon.modulate.a = 1
		parallax_bubbles.visible = true

func _spawn() -> void:
	Global.print_debug("Spawned new follower when day ended.")
	
	# Ramp up difficulty
	for i in range(Global.game_time_system._days):
		var follower_spawn_positions := get_tree().get_nodes_in_group("civillian_spawn_points")
		var follower_node: CivillianFollower = follower.instantiate()
		var spawn_node = follower_spawn_positions.pick_random()
		spawn_node.add_child(follower_node)
		follower_node.position += Util.random_vector(Global.rng, 50, 0)
		follower_spawned.emit(follower_node.global_position)
		if Global.is_multiplayer_host():
			Global.godot_steam_abstraction.run_remote_function(self, "_spawn_remote", [
				str(get_path_to(spawn_node)), 
				follower_node.global_position, 
				follower_node.name, 
				Global.game_time_system._days
			])

func _spawn_remote(spawn_pos: String, pos: Vector2, custom_name: String, amount: int) -> void:
	for i in range(amount):
		var follower_node: CivillianFollower = follower.instantiate()
		follower_node.name = custom_name
		get_node(spawn_pos).add_child(follower_node, true)
		follower_node.global_position = pos
		follower_spawned.emit(follower_node.global_position)

func _area_entered(area: Area2D) -> void:
	if !area.is_in_group("player_area") || !black_background || (!Global.player == area.get_parent().get_parent() && Global.player._is_node_owner()):
		return
	
	player_in_area = true

func _area_exited(area: Area2D) -> void:
	if !area.is_in_group("player_area") || !black_background || (!Global.player == area.get_parent().get_parent() && Global.player._is_node_owner()):
		return
	
	player_in_area = false

func _gravity_area_exited(area: Area2D) -> void:
	if !area.is_in_group("player_area"):
		return
