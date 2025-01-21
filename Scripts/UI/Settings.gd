extends Control

@onready var backButton = get_node("backButton")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	backButton.pressed.connect(func(): self.visible = false)
	
