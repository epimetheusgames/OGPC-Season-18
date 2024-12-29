## Customizeable cone of fire for guns

class_name ConeOfFire
extends Node2D

const LINE_LENGTH: float = 200.0

@export var range: float = 100.0

@export var max_spread_angle: float = 30.0
@export var min_spread_angle: float = 5.0
@export var spread_recovery_rate: float = 30.0  # Degrees per second

@onready var line1: Node2D = $"Line1"
@onready var line2: Node2D = $"Line2"

var spread_angle_degrees: float

func _ready() -> void:
	spread_angle_degrees = min_spread_angle
	
	line1.scale.x = range / LINE_LENGTH
	line2.scale.x = range / LINE_LENGTH

func increase_spread(angle_degrees: float) -> void:
	spread_angle_degrees += angle_degrees

func _process(delta: float) -> void:
	spread_angle_degrees -= spread_recovery_rate * delta
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
