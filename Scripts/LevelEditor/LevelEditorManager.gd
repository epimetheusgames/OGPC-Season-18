extends Node


func _on_window_close_requested() -> void:
	$Window.visible = false
