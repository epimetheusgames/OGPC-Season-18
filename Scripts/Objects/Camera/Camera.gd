extends Camera2D

@export var target_node: Node2D

func _process(_delta: float) -> void:
	global_position = target_node.global_position


func shake(force: int, duration: float) -> void:
	var timer = get_tree().create_timer(duration)
	var original_position: Vector2 = global_position
	
	while timer.time_left > 0:
		var rand: Vector2 = Vector2(randi_range(-force, force), randi_range(-force, force))
		global_position = original_position + rand
		await get_tree().process_frame
