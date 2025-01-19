class_name Dummy
extends Entity

@onready var health: HealthComponent = $"HealthComponent"
@onready var label: Label = $"Label"

func _process(delta: float) -> void:
	label.text = "Health: " + str(health.get_health())
