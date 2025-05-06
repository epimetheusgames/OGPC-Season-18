class_name DiverCamera
extends Camera2D

var target_position: Vector2

@onready var diver: Diver = get_parent()

func _ready() -> void:
	pass
	#shake(10, 1

func _process(delta: float) -> void:
	if diver._is_node_owner():
		enabled = true
	else:
		enabled = false

func shake(force: int, duration: float) -> void:
	var timer = get_tree().create_timer(duration)
	var original_position: Vector2 = global_position
	
	while timer.time_left > 0:
		if !get_tree().paused:
			var rand: Vector2 = Vector2(randi_range(-force, force), randi_range(-force, force))
			offset = rand
		await get_tree().process_frame
		
