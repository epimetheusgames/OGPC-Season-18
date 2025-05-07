class_name KelpSegment
extends Node2D

const segment_frames: int = 14

func _ready() -> void:
	randomize_frame()

func randomize_frame() -> void:
	$KelpSegment.frame = randi_range(0, segment_frames)
