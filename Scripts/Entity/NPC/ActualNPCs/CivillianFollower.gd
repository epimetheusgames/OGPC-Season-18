class_name CivillianFollower
extends Entity

@export var navigation: NavigationAgent2D
@export var following: CivillianFollower
@export var start_of_chain := false
@export var use_offset_position := true
@export var swim_speed: float
@export var follow_distance: float

var target_path_position: Vector2

func _ready() -> void:
	if !following: 
		Global.
	
	while true:
		await get_tree().create_timer(0.1).timeout
		navigation.target_position = following.get_follow_position()
		target_path_position = navigation.get_next_path_position()

func _process(delta: float) -> void:
	global_position += (target_path_position - global_position).normalized() * swim_speed * delta * 60

# Gets position the following civillian should navigate to, in global coordinates.
func get_follow_position() -> Vector2:
	if !use_offset_position:
		return global_position
	return global_position - (target_path_position - global_position).normalized() * follow_distance
