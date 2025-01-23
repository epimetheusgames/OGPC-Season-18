class_name Knife
extends Weapon

@export var dist_from_head: float = 40.0
@export var spread_angle: float = 120.0
@export var slash_time: float = 0.1

@export var cooldown_time: float = 0.25  # Time in between shots
var cooldown_timer: Timer
var cooldown_timer_over: bool = true


var slash_toggle: bool = false
var slash_angle: float = 0.0

func _ready() -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	cooldown_timer.connect("timeout", _on_cooldown_timeout)
	
	slash_angle = spread_angle/2
	
	add_child(get_slash_area())


func get_slash_area() -> CollisionPolygon2D:
	var polygon := CollisionPolygon2D.new()
	
	var points: Array[Vector2] = []
	
	points.append(Vector2.ZERO)
	
	var spread_segments: int = 5
	var length: float = 100.0
	
	var angle_increment: float = deg_to_rad(spread_angle) / spread_segments
	var start_angle: float = -deg_to_rad(spread_angle) / 2
	
	for i in range(spread_segments + 1):
		var angle = start_angle + angle_increment * i
		var point = Util.angle_to_vector_radians(angle, length)
		points.append(point)
	
	polygon.polygon = points
	polygon.top_level = true
	return polygon


func _on_cooldown_timeout() -> void:
	cooldown_timer_over = true

func _process(delta: float) -> void:
	super(delta)
	
	if !enabled:
		visible = false
		return
	
	visible = true
	
	var angle_to_mouse: float = head_pos.angle_to_point(mouse_pos)
	angle_to_mouse += deg_to_rad(slash_angle)
	
	global_position = head_pos + Util.angle_to_vector_radians(angle_to_mouse, dist_from_head)
	
	global_rotation = angle_to_mouse

func attack() -> void:
	if enabled && cooldown_timer_over:
		perform_attack()
		animate_slash_angle()
		
		cooldown_timer_over = false
		cooldown_timer.start(cooldown_time)


func animate_slash_angle() -> void:
	var new_angle
	
	if slash_toggle:
		new_angle = spread_angle/2
	else:
		new_angle = -spread_angle/2
	
	slash_toggle = !slash_toggle
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "slash_angle", new_angle, slash_time)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.play()
