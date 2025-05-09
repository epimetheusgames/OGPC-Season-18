extends Node2D

@onready var hatch
@onready var hatch_navigation

var players_inside : int = 0

@export var max_rotation : float = -PI * 8 / 9
@export var rotation_rate : float = .5

func _ready() -> void:
	get_parent().sub_flipped.connect(flipped)

func flipped():
	max_rotation = -max_rotation

func set_node_variables() -> void:
	hatch = $"../Hatch"
	hatch_navigation = $"../NavigationObstacle/Hatch"

func _process(delta: float) -> void:
	if players_inside >= 1:
		rotation = Util.better_angle_lerp(rotation, max_rotation, rotation_rate, delta)
		hatch.rotation = Util.better_angle_lerp(hatch.rotation, max_rotation, rotation_rate, delta)
		hatch_navigation.rotation = Util.better_angle_lerp(hatch_navigation.rotation, max_rotation, rotation_rate, delta)
	else:
		rotation = Util.better_angle_lerp(rotation, 0.0, rotation_rate, delta)
		hatch.rotation = Util.better_angle_lerp(hatch.rotation, 0.0, rotation_rate, delta)
		hatch_navigation.rotation = Util.better_angle_lerp(hatch_navigation.rotation, 0.0, rotation_rate, delta)

func _on_hatch_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_area"):
		players_inside += 1

func _on_hatch_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_area"):
		players_inside -= 1
