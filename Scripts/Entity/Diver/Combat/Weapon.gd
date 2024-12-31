# Base class for any weapon
## Owned by: kaitaobenson

class_name Weapon
extends Node2D

@export var attack_cooldown: float = 5.0

@export var use_hand1: bool = false
@export var use_hand2: bool = false

var diver: Diver

var cooldown_timer: Timer
var attack_cooldown_over: bool = true

var can_attack: bool = false

var head_pos: Vector2
var mouse_pos: Vector2

func _ready() -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	cooldown_timer.connect("timeout", _on_cooldown_timeout)

func _process(delta: float) -> void:
	head_pos = diver.diver_animation.get_head_position()
	mouse_pos = get_global_mouse_position()

func get_hand1_pos() -> Vector2:
	return Vector2.ZERO  # Override

func get_hand2_pos() -> Vector2:
	return Vector2.ZERO  # Override

func attack() -> void:
	if not attack_cooldown_over:
		return
	
	perform_attack()
	
	attack_cooldown_over = false
	cooldown_timer.start(attack_cooldown)

func perform_attack() -> void:
	pass  # Override

func _on_cooldown_timeout() -> void:
	print("reloaded")
	attack_cooldown_over = true
