class_name Dummy
extends Entity

@onready var hurtbox: Hurtbox = $"Hurtbox"
@onready var label: Label = $"Label"

func _process(delta: float) -> void:
	label.text = "Health: " + str(hurtbox.health)
