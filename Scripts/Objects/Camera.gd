class_name DiverCamera
extends Camera2D

var target_position: Vector2

func _ready() -> void:
	pass
	#shake(10, 1

func _process(delta: float) -> void:
	
	print(target_position)
	#global_position = target_position

func shake(force: int, duration: float) -> void:
	var timer = get_tree().create_timer(duration)
	var original_position: Vector2 = global_position
	
	while timer.time_left > 0:
		var rand: Vector2 = Vector2(randi_range(-force, force), randi_range(-force, force))
		offset = rand
		await get_tree().process_frame
