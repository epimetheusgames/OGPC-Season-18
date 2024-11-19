extends Node2D
signal interact

func _input(event):
	if(event.is_action_pressed("interact")):
		interact.emit()
