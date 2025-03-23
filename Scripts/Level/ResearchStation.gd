class_name ResearchStation
extends Node2D

@export var position_node: Node2D
@export var follower_spawn_node: Node2D
@export var black_background: ColorRect
@export var research_station_area: Area2D
@export var gravity_area: Area2D
@export var exterior_polygon: Polygon2D
@export var parallax_bubbles: ParallaxBackground
@export var follower: PackedScene

var player_in_area := false

func _ready() -> void:
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
	follower_spawn_node.add_child(follower.instantiate())

func _area_entered(area: Area2D) -> void:
	if !area.is_in_group("player_area") || !black_background:
		return
	
	player_in_area = true

func _area_exited(area: Area2D) -> void:
	if !area.is_in_group("player_area") || !black_background:
		return
	
	player_in_area = false

func _gravity_area_exited(area: Area2D) -> void:
	if !area.is_in_group("player_area"):
		return
	
	var stats: DiverStats = area.get_parent()
	stats.diver.diver_movement.velocity.x += 0
