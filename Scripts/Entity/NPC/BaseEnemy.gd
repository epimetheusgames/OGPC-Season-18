## A base class for all enemies.
## Extending enemies must call super() at the top
## of your process and ready functions

# Owned by: carsonetb
class_name Enemy
extends Entity

## Settings object that determines the enemy's behavior.
@export var settings: EnemyBehaviorSettings

## The distance considered "reached" for a navigation target.
@export var target_reached_min_dst: int = 10

## The direction the enemy is facing when initialised (local)
@export var forward_direction: Vector2 = Vector2(-1, 0)

## Enemy hurtbox area.
@export var hurtbox: Hurtbox

## Enemy attackbox area.
@export var attackbox: Attackbox

## Area to detect light, optional.
@export var light_detector: Area2D

## Debug variable to disable all enemy behavior.
@export var quick_disable_everything := false

## The detection area for the player, fetched on ready.
var _player_detection_area: Area2D

## The collision shape attached to the player detection area.
var _player_detection_collision_shape: CollisionShape2D

## Set via update_closest_player, the closest player by distance to the enemy.
## This will be the player that is visible because only the closest player is 
## checked.
var closest_player: Diver

## If the player is in the detection area, regardless of visibility.
var player_in_area := false

## If the player is in the area, and visible via a raycast.
var player_visible := false

## If the enemy has reached its target navigation position.
var reached_target := false

## If a light is visible.
var light_visible := false

## High level state.
var wander_state := WANDER_MODE.NOT_WANDERING

## The number of players in the detection area, regardless of visibility.
var num_players_in_area = 0

## List of active players in the lobby.
var players_list = []

## Current health of the enemy.
var health: float

## Navigation target pos.
var target_position: Vector2

## Default speed of the enemy, set by enemy_behavior_settings.
var target_speed: float

## High level state enum.
enum WANDER_MODE {
	WANDER_POINT_REACHED,
	WANDERING_TO_POINT,
	NOT_WANDERING,
}

func _ready() -> void:
	if quick_disable_everything:
		return
	
	if !settings:
		Global.print_error("ERROR: Enemy at path " + str(get_path()) + " doesn't have an EnemyBehaviorSettings.")
		return
	
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
	
	if attackbox:
		attackbox.damage_amount = settings.damage
	
	if hurtbox:
		hurtbox.damaged.connect(_take_damage)
	
	if settings.player_shines_light:
		if !light_detector:
			Global.print_error("ERROR: Enemy at path " + str(get_path()) + " has no light detector.")
			return
		
		light_detector.collision_layer = 0
		light_detector.collision_mask = Global.bitmask_conversion["Light"]
		light_detector.area_entered.connect(_light_entered)
		light_detector.area_exited.connect(_light_exited)

func _process(delta: float) -> void:
	super(delta)
	
	if quick_disable_everything:
		return
	
	if num_players_in_area == 0:
		player_in_area = false
		player_visible = false
	else:
		player_in_area = true
	
	if player_in_area:
		_update_closest_player()
		_update_player_visible()
	
	if hurtbox:
		health = hurtbox.health
	
	if health <= 0:
		_die()
	
	target_speed = settings.base_speed
	
	# Sync variables so that everything's the same.
	if Global.is_multiplayer && has_multiplayer_sync && _is_node_owner():
		Global.godot_steam_abstraction.sync_var(self, "health")
		
		if attackbox:
			Global.godot_steam_abstraction.sync_var(attackbox, "health")
		
	# If player in area calculate closest player, else wander.
	if player_visible:
		_update_target_position()
		target_speed *= 1 + settings.agressiveness
		
		var dist_to_player = position.distance_to(closest_player.position)
		if attackbox && dist_to_player < settings.attack_distance:
			attack()
		
		if dist_to_player < settings.closest_distance:
			target_position = position
		
	elif wander_state == WANDER_MODE.NOT_WANDERING || wander_state == WANDER_MODE.WANDER_POINT_REACHED:
		if settings.wander_type == EnemyBehaviorSettings.WANDER_TYPE.ATTACH_TO_WALL && !(wander_state == WANDER_MODE.NOT_WANDERING):
			return
		
		_update_wander_point()

## Signal, enemy detected light.
func _light_entered(_area: Area2D):
	light_visible = true

## Signal, enemy cannot see light anymore.
func _light_exited(_area: Area2D):
	light_visible = false

## Signal, takes damage.
func _take_damage(new_health: float) -> void:
	health -= new_health
	if health <= 0:
		_die()

## Signal, navigation target reached.
func _target_reached() -> void:
	reached_target = true
	wander_state = WANDER_MODE.WANDER_POINT_REACHED

## Kills enemy (with queue_free)
func _die() -> void:
	if settings.drops_item:
		var item_drop: Node2D = load(settings.drops_item.file).instantiate()
		get_parent().add_child.call_deferred(item_drop)
		item_drop.global_position = global_position
	queue_free()

# Overridable by children.
func attack() -> void:
	attackbox.is_attacking = true
	await get_tree().create_timer(0.1).timeout
	attackbox.is_attacking = false

## Generates circular view polygon based on arguments.
func _generate_view_polygon(angle: float, radius: float) -> PackedVector2Array:
	var output := PackedVector2Array([Vector2(0, 0)])
	var start := int(rad_to_deg(forward_direction.normalized().angle()))
	for i in range(start - int(int(angle) / 2.0), start + int((angle) / 2.0), 10):
		var fi = i * PI / 180
		output.append(Vector2(radius * cos(fi), radius * sin(fi)))
	
	return output

## Updates the local closest player variable.
func _update_closest_player():
	# If there is one player
	if num_players_in_area == 1:
		closest_player = players_list[0]
		
	# Else find the closest player
	else:
		var closest_dist := 99999999.0
		var closest_ind := 0
		for i in range(players_list.size()):
			var distance: float = position.distance_to(players_list[i].position)
			if distance < closest_dist:
				closest_dist = distance
				closest_ind = i
		
		closest_player = players_list[closest_ind]

## Updates the local player visible variable (via raycast).
func _update_player_visible():
	if closest_player.global_position.distance_squared_to(Global.research_station.position_node.global_position) < 1000 ^ 2:
		player_visible = false
		return 
	
	# If player is in submarine, impossible to see them.
	var state := closest_player.get_state()
	if state == Util.DiverState.IN_SUBMARINE || state == Util.DiverState.DRIVING_SUBMARINE:
		player_visible = false
		return
	
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
		print("WARNING: Raycast to player got no result, an enemy is at the same position as the player. This isn't good.")

## High level, updates target position, whether attacking or wandering.
func _update_target_position():
	wander_state = WANDER_MODE.NOT_WANDERING
	
	if player_visible:
		if settings.attack_mode == EnemyBehaviorSettings.ATTACK_MODE.ATTACK:
			if global_position.distance_squared_to(closest_player.global_position) > 800 ** 2:
				target_position = closest_player.position + -Util.angle_to_vector_radians(closest_player.global_rotation - PI / 2.0, 800)
			else:
				target_position = closest_player.position
		elif settings.attack_mode == EnemyBehaviorSettings.ATTACK_MODE.RUN:
			target_position = position - (closest_player.position - position)
	
	if light_visible && settings.player_shines_light && global_position.distance_squared_to(closest_player.global_position) > 200 ** 2:
		target_position = closest_player.position + -Util.angle_to_vector_radians(closest_player.global_rotation, 700)

## If wandering, finds a valid point to wander to.
func _update_wander_point():
	var valid_point_found := false
	var space_state := get_world_2d().direct_space_state
	var points_tested := 0
	
	while !valid_point_found:
		var rng := RandomNumberGenerator.new()
		var random_direction := Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)).normalized()
		
		if points_tested > 100:
			Global.print_error("Something bad happened while updating the wander point.")
			return
		
		if settings.wander_type == EnemyBehaviorSettings.WANDER_TYPE.RANDOM_POSITION || points_tested > 40:
			var random_multiplier := rng.randf_range(0, settings.wander_range)
			target_position = global_position + velocity.normalized() * settings.wander_range / 4 + random_direction * random_multiplier
			
			if target_position.distance_squared_to(Global.research_station.position_node.global_position) < 1000 ^ 2:
				continue
			
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
