class_name Knife
extends Weapon

@export var attackbox: Attackbox

@export var dist_from_head: float = 40.0
@export var spread_angle: float = 120.0
@export var slash_time: float = 0.05

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
	
	attackbox.connect("damage_delt", _hit_enemy)
	
	slash_angle = spread_angle/2


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
		attackbox.is_attacking = true
		attackbox.reset()
		
		perform_attack()
		animate_slash_angle()
		
		cooldown_timer_over = false
		cooldown_timer.start(cooldown_time)
		
		
		await get_tree().create_timer(slash_time + 0.05).timeout
		attackbox.is_attacking = false

func _hit_enemy() -> void:
	attackbox.is_attacking = false

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
