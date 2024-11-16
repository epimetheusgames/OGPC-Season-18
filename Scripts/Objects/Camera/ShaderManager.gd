extends Node

@export var pixelize_on: bool = true
@export var quantize_on: bool = true

@onready var pixelize_shader: ColorRect = $"BackBufferCopy1/ColorRect"
@onready var quantize_shader: ColorRect = $"BackBufferCopy2/ColorRect"

@onready var palette_loader: Node = $"PaletteLoader"

func _ready() -> void:
	# Get the palette colors
	palette_loader.load_colors()
	var palette: Array[Color] = palette_loader.get_colors()
	
	var vec4_palette = []
	for color in palette:
		var vec4_color = Vector4(color.r, color.g, color.b, color.a)
		vec4_palette.append(vec4_color)
	
	quantize_shader.material.set_shader_parameter("color_palette", vec4_palette)
	quantize_shader.material.set_shader_parameter("colors_amount", vec4_palette.size())
	
	# Set shader mats
	#if :
	#	pixelize_shader.material = null
	if true:
		pixelize_shader.material = null if not pixelize_on else pixelize_shader.material
		quantize_shader.material = null if not quantize_on else quantize_shader.material
