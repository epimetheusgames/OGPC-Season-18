extends Node

@export var palette: CompressedTexture2D
@export var size: int = 8

var colors: Array[Color] = []

func load_colors():
	if not palette:
		printerr("Palette image not set")
		print_stack()
		return
	
	var palette_image: Image = palette.get_image()
	
	# Height and width must be a multiple of 'size'
	assert(palette_image.get_height() % size == 0) 
	assert(palette_image.get_width() % size == 0)
	
	for i in range(0, palette_image.get_height(), size):
		for j in range(0, palette_image.get_width(), size):
			var color: Color = palette_image.get_pixel(j, i)
			
			if color.a > 0.0:
				colors.append(color)
	
	print("Colors amount: " + str(colors.size()))

func get_colors(): 
	return colors
