class_name CivillianFollower
extends Entity

@export var navigation: NavigationAgent2D
@export var following: CivillianFollower
@export var detection_area: Area2D
@export var start_of_chain := false
@export var use_offset_position := true
@export var swim_speed: float
@export var follow_distance: float 

var target_path_position: Vector2
var going_to_building := false
var is_in_gravity_area := false

func _ready() -> void:
	position += Util.random_vector(Global.rng, 50, 0)
	
	if !detection_area:
		Global.print_error("Follower at path " + str(get_path()) + " has no detection_area. Searching for one.")
		return
	
	if !detection_area.is_in_group("civillian_area"):
		Global.print_error("Follower at path " + str(get_path()) + " isn't in the right group.", Util.ErrorType.WARNING)
	
	if Global.save_load_framework:
		Global.save_load_framework.save_nodes.connect(_on_save_nodes)
	
	detection_area.area_entered.connect(_area_entered)
	detection_area.area_exited.connect(_area_exited)
	
	while true:
		await get_tree().create_timer(0.1).timeout
		
		if !following:
			continue
		
		navigation.target_position = following.get_follow_position()
		target_path_position = navigation.get_next_path_position()

func _on_save_nodes() -> void:
	Global.current_game_save.node_saves.append(NodeSaver.create(Global.current_mission_node, self, ["position", "rotation", "velocity"]))

func _physics_process(delta: float) -> void:
	if !following:
		if going_to_building:
			going_to_building = false
		return
		
	if global_position.distance_squared_to(navigation.target_position) < 5 ^ 2:
		return
	
	if !$AnimSkeleton/SwimmingAnimationPlayer.is_playing() && !is_in_gravity_area:
		$AnimSkeleton/SwimmingAnimationPlayer.play("LegOscillate")
	
	if going_to_building && global_position.distance_squared_to(following.global_position) < follow_distance ** 2:
		var building: PlaceableBuilding = following.get_parent()
		building.current_occupants += 1
		Global.player.diver_stats.current_money += 50
		queue_free()
	
	velocity = (target_path_position - global_position).normalized() * swim_speed
	rotation = Util.better_angle_lerp(rotation, velocity.angle() + PI / 2.0, 0.1, delta)
	
	if is_in_gravity_area:
		$AnimSkeleton/SwimmingAnimationPlayer.play("RESET")
		rotation = 0

	move_and_slide()

	position += velocity * delta * 60

## Gets position the following civillian should navigate to, in global coordinates.
func get_follow_position() -> Vector2:
	return global_position

func _area_entered(area: Area2D) -> void:
	if area.is_in_group("gravity_areas"):
		is_in_gravity_area = true
	
	if going_to_building:
		return

	if area.is_in_group("building_area"):
		var building: PlaceableBuilding = area.get_parent()

		if !building.player_follower_dummy:
			Global.print_error("Follower at path " + str(get_path()) + " cannot follow a building without a player follower dummy.")
			return
		if building.current_occupants >= building.max_occupants:
			return
		
		following = building.player_follower_dummy
		going_to_building = true
		return

	if following:
		return

	if area.is_in_group("civillian_area"):
		following = area.get_parent()
	if area.is_in_group("player_area"):
		following = Global.player.follower

func _area_exited(area: Area2D) -> void:
	if area.is_in_group("gravity_areas"):
		is_in_gravity_area = false
