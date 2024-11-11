extends Node2D


var static_occluders: Array[LightOccluder2D] = []
var moving_occluders: Array[LightOccluder2D] = []

@export var occluder_offset: Vector2

func _ready():
	var world = $WorldNode2D
	remove_child(world)
	$World.add_child(world)
	
	$World.size = get_viewport().size
	$StaticShadowPass.size = get_viewport().size
	$StaticShadowBlurPass.size = get_viewport().size
	$MovingShadowBlurPass.size = get_viewport().size
	$MovingShadowPass.size = get_viewport().size
	$WorldShadowBlendPass.size = get_viewport().size 
	
	# Find all the occluders in the scene and move them over.
	_recursively_search_for_occluders($World)
	
	$Final.visible = true
	
func _process(delta: float) -> void:
	# These static shadows aren't moving technically but they are relative to 
	# the player camera.
	_remove_all_occluders($StaticShadowPass/OccludersContainer)
	_remove_all_occluders($StaticShadowBlurPass/OccludersContainer)
	_remove_all_occluders($MovingShadowPass/OccludersContainer)
	_remove_all_occluders($MovingShadowBlurPass/OccludersContainer)
	
	for occluder in static_occluders:
		duplicate_occluder(occluder, $StaticShadowPass/OccludersContainer)
		duplicate_occluder(occluder, $StaticShadowBlurPass/OccludersContainer)
		
	for occluder in moving_occluders:
		duplicate_occluder(occluder, $MovingShadowPass/OccludersContainer)
		duplicate_occluder(occluder, $MovingShadowBlurPass/OccludersContainer)
	
func duplicate_occluder(occluder, on):
	var new_occluder = occluder.duplicate()
	new_occluder.position = occluder.global_position + occluder_offset - $World/WorldNode2D/Diver/Camera2D.global_position
	new_occluder.rotation = occluder.global_rotation
	on.add_child(new_occluder)
	on.scale = $World/WorldNode2D/Diver/Camera2D.zoom

func _recursively_search_for_occluders(root: Node):
	for node in root.get_children():
		if node is LightOccluder2D:
			if node.occluder_light_mask == 1:
				static_occluders.append(node)
			if node.occluder_light_mask == 2:
				moving_occluders.append(node)
			
		_recursively_search_for_occluders(node)

func _remove_all_occluders(on):
	for node in on.get_children():
		if node is LightOccluder2D:
			node.free()
