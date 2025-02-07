class_name Dummy
extends Entity

@onready var hurtbox = $"Hurtbox"
@onready var label = $"Label"

func _process(delta: float) -> void:
	label.text = "Health: " + str(hurtbox.health)
