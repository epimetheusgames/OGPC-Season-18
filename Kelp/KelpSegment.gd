class_name KelpSegment
extends AnimatedSprite2D

const segment_frames: int = 14

func _ready() -> void:
	randomize_frame()

func randomize_frame() -> void:
	frame = randi_range(0, segment_frames)
