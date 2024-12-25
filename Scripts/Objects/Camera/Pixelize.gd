@tool
extends BackBufferCopy

@export var pixel_size: int = 4

@onready var color_rect_material: ShaderMaterial = $"ColorRect".material

func _ready() -> void:
	set_shader_process(true)

func _process(delta: float) -> void:
	$ColorRect.size = get_viewport_rect().size
	color_rect_material.set_shader_parameter("screen_size", get_viewport_rect().size)

func set_shader_process(turned_on: bool):
	if turned_on:
		turn_on()
	else:
		turn_off()

func turn_on():
	color_rect_material.set_shader_parameter("pixel_size", pixel_size)
	visible = true

func turn_off():
	visible = false
