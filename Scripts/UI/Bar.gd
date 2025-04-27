extends TextureProgressBar

@export var shake_below_value: float = 10.0

@export var shake_force: float = 3.0

var shake_time_left: float = 0.0

func _ready() -> void:
	value_changed.connect(shake)

func _process(delta: float) -> void:
	if shake_time_left > 0.0 || value < shake_below_value:
		shake_time_left -= delta
		position = Vector2(randf_range(-shake_force, shake_force), randf_range(-shake_force, shake_force))
	else:
		position = Vector2.ZERO

func shake(value: float) -> void:
	shake_time_left = 0.6
