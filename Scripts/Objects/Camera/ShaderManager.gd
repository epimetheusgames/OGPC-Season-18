extends Node

@export var shaders_in_editor: bool = false

@export var pixelize_on: bool = true
@export var quantize_on: bool = true

@onready var pixelize_shader: ShaderMaterial = $"BackBufferCopy1/ColorRect".material
@onready var quantize_shader: ShaderMaterial = $"BackBufferCopy2/ColorRect".material

@onready var palette_loader: Node = $"PaletteLoader"

func _ready() -> void:
	# Get the palette colors
	palette_loader.load_colors()
	var palette: Array[Color] = palette_loader.get_colors()
	
	var vec4_palette = []
	for color in palette:
		var vec4_color = Vector4(color.r, color.g, color.b, color.a)
		vec4_palette.append(vec4_color)
	
	quantize_shader.set_shader_parameter("color_palette", vec4_palette)
	
	# Set shader mats
	var in_engine: bool = not Engine.is_editor_hint()
	var in_editor_and_enabled: bool = Engine.is_editor_hint() and shaders_in_editor
	
	if in_engine or in_editor_and_enabled:
		pixelize_shader.shader = null if not pixelize_on else pixelize_shader.shader
		quantize_shader.shader = null if not quantize_on else quantize_shader.shader
