extends Node


@export var shader_on: bool = true

@onready var palette_loader = $"PaletteLoader"
@onready var color_rect = $"ColorRect"

func _ready() -> void:
	#bye await palette_loader.ready
	var palette = palette_loader.get_palette_colors()
	print("SKIBDIIDFS")
	print(palette)
	
	var rgb_palette = []
	for color in palette:
		var color_vec4 = Vector4(color.r, color.g, color.b, color.a)
		rgb_palette.append(color_vec4)
	
	var mat: ShaderMaterial = color_rect.material
	mat.set_shader_parameter("color_palette", rgb_palette)
