class_name DiverCamera
extends Camera2D

var target_zoom: Vector2
var target_position: Vector2

var shake_force: float
var shake_duration: float

func _ready() -> void:
	shake(5, 10)

func _process(delta: float) -> void:
	global_position = global_position + (target_position - global_position) * 0.5
	zoom = zoom + (target_zoom - zoom) * 0.5
	
	if shake_duration > 0:
		shake_duration -= delta
		var rand := Vector2(randf_range(-shake_force, shake_force), randf_range(-shake_force, shake_force))
		offset = rand


func shake(force: int, duration: float) -> void:
	shake_force = force
	shake_duration = duration
