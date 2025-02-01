extends Enemy
class_name BiterFish

var group: Array[Enemy] = []
var nav_target: Vector2
@export var max_group_center_dist := 900.0

func _ready() -> void:
	super()
	
	while true:
		await get_tree().create_timer(0.1).timeout
		$Nav.target_position = target_position
		nav_target = $Nav.get_next_path_position()
		if !$Nav.is_target_reachable():
			_target_reached()

func _process(delta: float) -> void:
	super(delta)
	
	var target_velocity := (nav_target - global_position).normalized() * target_speed 
	var target_rotation := velocity.angle() + PI 
	
	velocity = Util.better_vec2_lerp(velocity, target_velocity, 0.1, delta)
	global_rotation = Util.better_angle_lerp(global_rotation, target_rotation, 0.3, delta)
	global_position += velocity * delta * 60
	
	var average_position := global_position
	var num = 1
	for fish in group:
		if !is_instance_valid(fish):
			continue
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
