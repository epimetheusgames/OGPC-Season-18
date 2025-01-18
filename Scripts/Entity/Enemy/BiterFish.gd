extends Enemy
class_name BiterFish

var group: Array[Enemy] = []
@export var max_group_center_dist := 900.0

func _process(delta: float) -> void:
	super(delta)
	
	$NavAgent.target_position = target_position
	var path_pos: Vector2 = $NavAgent.get_next_path_position()
	
	var target_velocity := (path_pos - global_position).normalized() * target_speed 
	var target_rotation := velocity.angle() + PI 
	
	velocity = Util.better_vec2_lerp(velocity, target_velocity, 0.1, delta)
	global_rotation = Util.better_angle_lerp(global_rotation, target_rotation, 0.3, delta)
	global_position += velocity * delta * 60
	
	var average_position := global_position
	var num = 1
	for fish in group:
		if fish == self:
			continue
		average_position += fish.global_position
		num += 1
	average_position /= num
	
	if global_position.distance_squared_to(average_position) > max_group_center_dist ** 2:
		global_position = average_position + average_position.direction_to(global_position) * max_group_center_dist
		velocity = -velocity
	
	if position.distance_to(target_position) < 50:
		_target_reached()
