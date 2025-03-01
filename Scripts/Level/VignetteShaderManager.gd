extends BackBufferCopy

func _ready() -> void:
	visible = true

func _process(delta: float) -> void:
	$ColorRect.size = get_viewport_rect().size
	var mat: ShaderMaterial = $ColorRect.material
	if Global.player.position.y > 1000 && mat.get_shader_parameter("vignette_strength") < 1:
		mat.set_shader_parameter("vignette_strength", mat.get_shader_parameter("vignette_strength") + 0.005 * delta * 60)
	elif mat.get_shader_parameter("vignette_strength") > 0:
		mat.set_shader_parameter("vignette_strength", mat.get_shader_parameter("vignette_strength") - 0.005 * delta * 60)
