extends CanvasLayer

@export var quantize_on: bool = true
@export var pixelize_on: bool = true

@onready var quantize_shader: BackBufferCopy = $"Quantize"
@onready var pixelize_shader: BackBufferCopy = $"Pixelize"

func _ready() -> void:
	if Engine.is_editor_hint():
		quantize_shader.set_shader_process(false)
		pixelize_shader.set_shader_process(false)
	else:
		if quantize_on:
			quantize_shader.set_shader_process(true)
		else:
			quantize_shader.set_shader_process(false)
		
		if pixelize_on:
			pixelize_shader.set_shader_process(true)
		else:
			pixelize_shader.set_shader_process(false)
