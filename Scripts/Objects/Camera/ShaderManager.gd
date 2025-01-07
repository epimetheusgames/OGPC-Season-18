@tool
extends CanvasLayer

@export var quantize_on: bool = true
@export var pixelize_on: bool = true

@onready var quantize_shader: BackBufferCopy = $"Quantize"
@onready var pixelize_shader: BackBufferCopy = $"Pixelize"

func _ready() -> void:
	$Pixelize/ColorRect.size = DisplayServer.window_get_size()
	$Rain/ColorRect.size = DisplayServer.window_get_size()
	$Quantize/ColorRect.size = DisplayServer.window_get_size()
	$Vignette/ColorRect.size = DisplayServer.window_get_size()
	
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
