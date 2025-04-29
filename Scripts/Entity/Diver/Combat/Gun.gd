# Base class for guns
## Owned by: kaitaobenson

class_name Gun
extends Weapon

enum GunState {
	HOLDING,
	AIMING,
}

@export var bullet_scene: PackedScene
@export var max_bullet_amount: int = 5  # Amount of bullets per magazine / before reload
@onready var bullets_left: int = max_bullet_amount

@export var reload_time: float = 2.0  # Time it takes for reload
var reload_timer: Timer
var reload_timer_over: bool = true

@export var cooldown_time: float = 0.1  # Time inbetween shots
var cooldown_timer: Timer
var cooldown_timer_over: bool = true

@export var dist_from_head: float = 100.0
@export var knockback: float = 10.0

signal shot()
signal reload_start()
signal reload_finish()

var gun_state := GunState.HOLDING


func _ready() -> void:
	reload_timer = Timer.new()
	reload_timer.one_shot = true
	add_child(reload_timer)
	reload_timer.connect("timeout", _on_reload_timeout)
	
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	cooldown_timer.connect("timeout", _on_cooldown_timeout)

func _on_reload_timeout() -> void:
	reload_timer_over = true
	bullets_left = max_bullet_amount
	reload_finish.emit()

func _on_cooldown_timeout() -> void:
	cooldown_timer_over = true

func _process(delta: float) -> void:
	super(delta)
	
	if Global.godot_steam_abstraction && Global.is_multiplayer && !Global.player._is_node_owner():
		return
	
	if !enabled:
		visible = false
		return
	
	visible = true
	
	var bar_val: float = (reload_timer.time_left) / reload_time * 100.0
	Global.player.diver_combat.set_reload_bar(bar_val)
	
	var dir: Vector2 = mouse_pos - head_pos
	global_position = head_pos + dir.normalized() * dist_from_head
	
	var rot: float = head_pos.angle_to_point(mouse_pos)
	global_rotation = rot
	
	var deg_rot: float = Util.normalize_angle_degrees(rad_to_deg(rot))
	
	if Global.godot_steam_abstraction && Global.is_multiplayer:
		Global.godot_steam_abstraction.run_remote_function(Global.player.diver_combat, "set_reload_bar", [bar_val])
		Global.godot_steam_abstraction.sync_var(self, "global_position")
		Global.godot_steam_abstraction.sync_var(self, "global_rotation")
		Global.godot_steam_abstraction.sync_var(self, "scale")
		Global.godot_steam_abstraction.sync_var(self, "visible")

func attack() -> void:
	if !reload_timer_over or !cooldown_timer_over:
		return
	
	cooldown_timer_over = false
	perform_attack()
	shot.emit()
	bullets_left -= 1
	
	if bullets_left == 0:
		reload_timer_over = false
		reload_timer.start(reload_time)
		reload_start.emit()
	
	cooldown_timer.start(cooldown_time)
