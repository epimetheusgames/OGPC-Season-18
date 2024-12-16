extends BackBufferCopy

@export var shader: Shader
@export var pixel_size: int = 4

@onready var color_rect_material: ShaderMaterial = $"ColorRect".material

func _ready() -> void:
	set_shader_process(true)

func set_shader_process(turned_on: bool):
	if turned_on:
		turn_on()
	else:
		turn_off()

func turn_on():
	color_rect_material.shader = shader
	color_rect_material.set_shader_parameter("pixel_size", pixel_size)

func turn_off():
	color_rect_material.shader = null
