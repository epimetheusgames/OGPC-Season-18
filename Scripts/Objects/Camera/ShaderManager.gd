# Handles post processing shaders

extends CanvasLayer

@onready var posterize: ShaderMaterial = $"Posterize/ColorRect".material
@onready var pixelize: ShaderMaterial = $"Pixelize/ColorRect".material

var posterize_level: float = 4.0
var pixelize_level: float = 4.0

func _ready() -> void:
	posterize_level = posterize.get_shader_parameter("posterization_level")
	pixelize_level = pixelize.get_shader_parameter("pixelization_level")

func set_posterize_level(level: float):
	posterize_level = level
	posterize.set_shader_parameter("posterization_level", posterize_level)

func set_pixelize_level(level: float):
	pixelize_level = level
	pixelize.set_shader_parameter("pixelization_level", pixelize_level)
