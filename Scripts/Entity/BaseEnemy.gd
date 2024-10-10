## A base class for all enemies.
## If inheriting from this class you must call _process_enemy at the start of your 
## process function.
class_name Enemy
extends NPC

@export var settings: EnemyBehaviorSettings
@export_node_path("Area2D") var _player_detection_area_node_path

var _player_detection_area: Area2D
var player_in_area = false
var num_players_in_area = 0
var players_list = []

## TODO: IMPLEMENT ENEMY BEHAVIOR SETTINGS

func _ready():
	_player_detection_area = get_node(_player_detection_area_node_path)
	_player_detection_area.area_entered.connect(_area_entered)
	_player_detection_area.area_exited.connect(_area_exited)

func _process(delta: float) -> void:
	_process_enemy(delta)

func _process_enemy(delta: float) -> void:
	if num_players_in_area == 0:
		player_in_area = false
	else:
		player_in_area = true

func _area_entered(area: Area2D) -> void:
	if area.name == "PlayerHurtbox":
		num_players_in_area += 1
		players_list.append(area.get_parent())

func _area_exited(area: Area2D) -> void:
	if area.name == "PlayerHurtbox":
		num_players_in_area -= 1
		players_list.remove_at(players_list.find(area.get_parent()))
		
