## A base class for all enemies.
## If inheriting from this class you must call _process_enemy at the start of your 
## process function, and call _enemy_ready at the start of your ready function.
class_name Enemy
extends NPC

@export var settings: EnemyBehaviorSettings

var _player_detection_area: Area2D
var _player_detection_collision_shape: CollisionShape2D
var closest_player: Diver
var player_in_area = false
var num_players_in_area = 0
var players_list = []

var health: int

## TODO: IMPLEMENT ENEMY BEHAVIOR SETTINGS

func _ready():
	_enemy_ready()

func _enemy_ready() -> void:
	_player_detection_area = Area2D.new()
	_player_detection_area.collision_layer = 0
	if settings.sensor_type == EnemyBehaviorSettings.SENSOR_TYPE.LIGHT:
		_player_detection_area.collision_mask = 4
	if settings.sensor_type == EnemyBehaviorSettings.SENSOR_TYPE.NOISE:
		_player_detection_area.collision_mask = 8
	if settings.sensor_type == EnemyBehaviorSettings.SENSOR_TYPE.MOTION:
		_player_detection_area.collision_mask = 16
	
	_player_detection_collision_shape = CollisionShape2D.new()
	_player_detection_collision_shape.shape = CircleShape2D.new()
	
	_player_detection_area.area_entered.connect(_area_entered)
	_player_detection_area.area_exited.connect(_area_exited)
	
	add_child(_player_detection_area)
	_player_detection_area.add_child(_player_detection_collision_shape)
	
	# Initialize enemy behavior settings.
	health = settings.health
	_player_detection_collision_shape.shape.radius = settings.view_distance

func _process(delta: float) -> void:
	_process_enemy(delta)

func _process_enemy(delta: float) -> void:
	if num_players_in_area == 0:
		player_in_area = false
	else:
		player_in_area = true
	
	if player_in_area:
		# If there is one player, go towards that.
		if num_players_in_area == 1:
			closest_player = players_list[0]
			
		# Else find the closest player
		else:
			var closest_dist := 99999999
			var closest_ind := 0
			for i in range(players_list.size()):
				var distance: int = position.distance_to(players_list[i].position)
				if distance < closest_dist:
					closest_dist = distance
					closest_ind = i
			
			closest_player = players_list[closest_ind]

func _area_entered(area: Area2D) -> void:
	if area.name == "PlayerVisualDetectionArea":
		num_players_in_area += 1
		players_list.append(area.get_parent())

func _area_exited(area: Area2D) -> void:
	if area.name == "PlayerVisualDetectionArea":
		num_players_in_area -= 1
		players_list.remove_at(players_list.find(area.get_parent()))
		
