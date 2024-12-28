extends CharacterBody2D
class_name SubmarineModule

var attachment_points = Array[AttachmentPoint]

func _ready() -> void:
	if get_node_or_null("AttachmentPoints"):
		for child in $"AttachmentPoints".get_children():
			attachment_points.append(child)
