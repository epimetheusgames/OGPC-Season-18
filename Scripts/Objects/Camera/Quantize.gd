@tool
extends BackBufferCopy

@export var shader: Shader

@onready var palette_loader: Node2D = $"PaletteLoader"
@onready var color_rect_material: ShaderMaterial = $"ColorRect".material

var palette: Array[Color] = []
var vec4_palette: Array[Vector4] = []

func _ready() -> void:
	palette = palette_loader.get_colors()
	
	for color in palette:
		var vec4_color = Vector4(color.r, color.g, color.b, color.a)
		vec4_palette.append(vec4_color)
	
	set_shader_process(true)
	
	for color: Color in palette:
		print(color)

func set_shader_process(turned_on: bool):
	if turned_on:
		turn_on()
	else:
		turn_off()

func turn_on():
	color_rect_material.shader = shader
	color_rect_material.set_shader_parameter("color_palette", vec4_palette)
	color_rect_material.set_shader_parameter("colors_amount", vec4_palette.size())

func turn_off():
	color_rect_material.shader = null
