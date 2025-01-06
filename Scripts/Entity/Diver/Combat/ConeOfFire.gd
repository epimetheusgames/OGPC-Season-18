## Customizeable cone of fire for guns

class_name ConeOfFire
extends Node2D

const LINE_LENGTH: float = 200.0

@export var range: float = 100.0

@export var max_spread_angle: float = 30.0
@export var min_spread_angle: float = 5.0

@export var spread_decrease_factor: float = 20.0
@export var spread_increase_factor: float = 1.0

@onready var line1: Node2D = $"Line1"
@onready var line2: Node2D = $"Line2"

var spread_angle_degrees: float

var prev_pos: Vector2
var prev_rot: float

func _ready() -> void:
	spread_angle_degrees = max_spread_angle
	
	line1.scale.x = range / LINE_LENGTH
	line2.scale.x = range / LINE_LENGTH


func _process(delta: float) -> void:
	spread_angle_degrees -= spread_decrease_factor * delta
	
	var pos_dif = global_position.distance_to(prev_pos)
	prev_pos = global_position
	var rot_dif = angle_difference(global_rotation, prev_rot)
	prev_rot = global_rotation
	
	if get_parent().get_parent().name == "Speargun":
		print(pos_dif)
		print(rot_dif)
	spread_angle_degrees += (pos_dif * 10 + rot_dif * 30) * spread_increase_factor * delta
	
	spread_angle_degrees = clamp(spread_angle_degrees, min_spread_angle, max_spread_angle)
	
	line1.rotation_degrees = spread_angle_degrees / 2
	line2.rotation_degrees = -spread_angle_degrees / 2

# Gets random angle of shot within spread angle (Radians)
# Weighted towards center slightly
func get_shot_angle() -> float:
	var range: float = spread_angle_degrees / 2
	
	var t: float = randf() ** 1.5
	
	var random_angle: float = lerp(-range, range, t)
	return global_rotation + deg_to_rad(random_angle)
