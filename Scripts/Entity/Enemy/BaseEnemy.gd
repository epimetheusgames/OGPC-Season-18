## A base class for all enemies.
## If inheriting from this class you must call _process_enemy at the start of your 
## process function, and call _enemy_ready at the start of your ready function.
# Owned by: carsonetb
class_name Enemy
extends NPC

@export var settings: EnemyBehaviorSettings
@export var target_reached_min_dst: int = 10
@export var forward_direction: Vector2 = Vector2(-1, 0)
@export var hurtbox_component: HurtboxComponent
@export var attackbox_component: AttackBoxComponent
@export var health_component: HealthComponent

var _player_detection_area: Area2D
var _player_detection_collision_shape: CollisionShape2D
var closest_player: Diver
var player_in_area := false
var player_visible := false
var reached_target := false
var wander_state := WANDER_MODE.NOT_WANDERING
var num_players_in_area = 0
var players_list = []

var health: int
var target_position: Vector2
var target_speed: float

enum WANDER_MODE {
	WANDER_POINT_REACHED,
	WANDERING_TO_POINT,
	NOT_WANDERING,
}

func _ready():
	_enemy_ready()

func _enemy_ready() -> void:
	target_position = position
	
	_player_detection_area = Area2D.new()
	_player_detection_area.collision_layer = 0
	if settings.sensor_type == EnemyBehaviorSettings.SENSOR_TYPE.LIGHT:
		_player_detection_area.collision_mask = 4
	if settings.sensor_type == EnemyBehaviorSettings.SENSOR_TYPE.NOISE:
		_player_detection_area.collision_mask = 8
	if settings.sensor_type == EnemyBehaviorSettings.SENSOR_TYPE.MOTION:
		_player_detection_area.collision_mask = 16
	
	_player_detection_collision_shape = CollisionShape2D.new()
	
	var shape := ConvexPolygonShape2D.new()
	shape.points = _generate_view_polygon(settings.view_range, settings.view_distance)
	_player_detection_collision_shape.shape = shape
	
	_player_detection_area.area_entered.connect(_area_entered)
	_player_detection_area.area_exited.connect(_area_exited)
	
	add_child(_player_detection_area)
	_player_detection_area.add_child(_player_detection_collision_shape)
	
	# Initialize enemy behavior settings.
	health = settings.health
	
	if health_component:
		health_component.set_health(health)
		health_component.damage_taken.connect(_take_damage)

func _take_damage(new_health) -> void:
	health = new_health
	if health <= 0:
		queue_free()

func _target_reached() -> void:
	reached_target = true
	wander_state = WANDER_MODE.WANDER_POINT_REACHED

func _process(delta: float) -> void:
	_enemy_process(delta)

func _enemy_process(delta: float) -> void:
	_npc_process(delta)
	
	if num_players_in_area == 0:
		player_in_area = false
		player_visible = false
	else:
		player_in_area = true
	
	if player_in_area:
		_update_closest_player()
		_update_player_visible()
	
	target_speed = settings.base_speed
		
	# If player in area calculate closest player, else wander.
	if player_visible:
		_update_target_position()
		target_speed *= 1 + settings.agressiveness
		
		var dist_to_player = position.distance_to(closest_player.position)
		if attackbox_component && dist_to_player < settings.attack_distance && !attackbox_component.is_attacking:
			attackbox_component.attack()
			attack()
		
		if dist_to_player < settings.closest_distance:
			target_position = position
		
	elif wander_state == WANDER_MODE.NOT_WANDERING || wander_state == WANDER_MODE.WANDER_POINT_REACHED:
		if settings.wander_type == EnemyBehaviorSettings.WANDER_TYPE.ATTACH_TO_WALL && !(wander_state == WANDER_MODE.NOT_WANDERING):
			return
		
		_update_wander_point()

# Overridable by children.
func attack() -> void:
	pass

func _generate_view_polygon(angle: float, radius: float) -> PackedVector2Array:
	var output := PackedVector2Array([Vector2(0, 0)])
	var start := int(rad_to_deg(forward_direction.normalized().angle()))
	for i in range(start - int(angle) / 2, start + int(angle) / 2, 10):
		var fi = i * PI / 180
		output.append(Vector2(radius * cos(fi), radius * sin(fi)))
	
	return output

func _update_closest_player():
	# If there is one player
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

func _update_player_visible():
	var space_state := get_world_2d().direct_space_state
	var raycast := PhysicsRayQueryParameters2D.create(global_position, closest_player.global_position)
	var result := space_state.intersect_ray(raycast)
	if result:
		if result["collider"] == closest_player:
			player_visible = true
		else:
			# The fish will be able to see the player for a bit even after it leaves the area.
			if num_players_in_area == 1 && player_visible:
				await get_tree().create_timer(settings.disable_period_length).timeout
			player_visible = false
	else:
		print("WARNING: Raycast to player got no results???")

func _update_target_position():
	wander_state = WANDER_MODE.NOT_WANDERING
	
	if player_visible:
		if settings.attack_mode == EnemyBehaviorSettings.ATTACK_MODE.ATTACK:
			target_position = closest_player.position
		elif settings.attack_mode == EnemyBehaviorSettings.ATTACK_MODE.RUN:
			target_position = position - (closest_player.position - position)

func _update_wander_point():
	var valid_point_found := false
	var space_state := get_world_2d().direct_space_state
	var points_tested := 0
	
	while !valid_point_found:
		var rng := RandomNumberGenerator.new()
		var random_direction := Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)).normalized()
		
		if settings.wander_type == EnemyBehaviorSettings.WANDER_TYPE.RANDOM_POSITION || points_tested > 40:
			var random_multiplier := rng.randf_range(0, settings.wander_range)
			target_position = global_position + velocity.normalized() * settings.wander_range / 4 + random_direction * random_multiplier
			
			var pointcast = PhysicsPointQueryParameters2D.new()
			pointcast.position = target_position
			var result = space_state.intersect_point(pointcast)
			
			# We didn't colide with anything.
			if !result:
				valid_point_found = true
	
		# If this is our first update to wander then do that.
		elif settings.wander_type == EnemyBehaviorSettings.WANDER_TYPE.ATTACH_TO_WALL:
			var raycast = PhysicsRayQueryParameters2D.create(global_position, global_position + random_direction * settings.wander_range)
			var result = space_state.intersect_ray(raycast)
			
			if result:
				valid_point_found = true
				target_position = result["position"] + result["normal"] * 50
		
		points_tested += 1
		
	reached_target = false
	wander_state = WANDER_MODE.WANDERING_TO_POINT

func _area_entered(area: Area2D) -> void:
	if area.name == "PlayerVisualDetectionArea":
		num_players_in_area += 1
		players_list.append(area.get_parent())

func _area_exited(area: Area2D) -> void:
	if area.name == "PlayerVisualDetectionArea":
		# The fish will be able to see the player for a bit even after it leaves the area.
		if num_players_in_area == 1 && player_visible:
			await get_tree().create_timer(settings.disable_period_length).timeout
		
		num_players_in_area -= 1
		players_list.remove_at(players_list.find(area.get_parent()))
