extends Sprite2D

@onready var rope: VerletRope = $"../VerletRope"

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
