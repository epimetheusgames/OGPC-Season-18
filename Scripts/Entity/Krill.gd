class_name Krill
extends Entity

@export var sine_height := 100
@export var sine_speed := 1.0 # Waves per second

var x := 0.0
var original_position: Vector2

func _ready() -> void:
	original_position = position

func _process(delta: float) -> void:
	x += delta
	position = Vector2(0, original_position.y + sin(x * 2 * PI * sine_speed) * sine_height)
