extends BackBufferCopy

@onready var mat:ShaderMaterial = get_node("ColorRect").material 
@export var settings: Control
@onready var brightnessSlider: HSlider = settings.brightnessSlider
var b
func _brightness_changed():
	if(brightnessSlider.value!=0):
		b = brightnessSlider.value/100
		mat.set_shader_parameter("brightness",b)
	else:
		mat.set_shader_parameter("brightness",0.0)
