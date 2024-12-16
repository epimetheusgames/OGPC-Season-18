extends Sprite2D

@onready var rope: VerletRope = $"../VerletRope"

func _ready() -> void:
	rope.start_pos_on = true

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	rope.start_pos = global_position
