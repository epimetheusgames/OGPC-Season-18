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

func _ready() -> void:
	if !detection_area:
		Global.print_error("Follower at path " + str(get_path()) + " has no detection_area.")
		return
	
	if !detection_area.is_in_group("civillian_area"):
		Global.print_error("Follower at path " + str(get_path()) + " isn't in the right group.", Util.ErrorType.WARNING)
	
	detection_area.area_entered.connect(_area_entered)
	
	while true:
		await get_tree().create_timer(0.1).timeout
		
		if !following:
			continue
		
		navigation.target_position = following.get_follow_position()
		target_path_position = navigation.get_next_path_position()

func _process(delta: float) -> void:
	if !following:
		return
		
	if global_position.distance_squared_to(navigation.target_position) < 5 ^ 2:
		return
	
	velocity = (target_path_position - global_position).normalized() * swim_speed * delta * 60

	move_and_slide()

	position += velocity * delta * 60

## Gets position the following civillian should navigate to, in global coordinates.
func get_follow_position() -> Vector2:
	return global_position

func _area_entered(area: Area2D) -> void:
	if area.is_in_group("civillian_area"):
		following = area.get_parent()
	if area.is_in_group("player_area"):
		following = Global.player.follower
