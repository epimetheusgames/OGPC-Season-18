# Owned by: carsonetb
class_name ShadowPipeline
extends Node

var static_occluders: Array[LightOccluder2D] = []
var moving_occluders: Array[LightOccluder2D] = []

@export var level_container: Node2D
@export var camera: Node2D
@export var occluder_offset: Vector2
@onready var disabled = Global.super_efficient
@export var world_vieport: ViewportTexture
@export var enable_shadows := true

func _ready():
	if !enable_shadows:
		queue_free()
		return
	
	var parent = level_container.get_parent()
	parent.remove_child.call_deferred(level_container)
	$WorldContainer/World.add_child.call_deferred(level_container)
	
	$WorldContainer/World.size = get_viewport().size
	$StaticShadowPass.size = get_viewport().size
	$StaticShadowBlurPass.size = get_viewport().size
	$MovingShadowBlurPass.size = get_viewport().size
	$MovingShadowPass.size = get_viewport().size
	$WorldShadowBlendPass.size = get_viewport().size 
	
	if disabled:
		$StaticShadowPass.queue_free()
		$StaticShadowBlurPass.queue_free()
		$MovingShadowPass.queue_free()
		$MovingShadowBlurPass.queue_free()
		$WorldShadowBlendPass.queue_free()
		
		$Final.texture = world_vieport
	
	# Find all the occluders in the scene and move them over.
	_recursively_search_for_occluders.call_deferred($WorldContainer/World)
	
	$Final.visible = true
	
func _process(_delta: float) -> void:
	if disabled:
		return
	
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
	if !is_instance_valid(occluder):
		return
	var new_occluder = occluder.duplicate()
	new_occluder.position = occluder.global_position + occluder_offset - camera.global_position
	new_occluder.rotation = occluder.global_rotation
	on.add_child(new_occluder)
	on.scale = camera.zoom

func _recursively_search_for_occluders(root: Node):
	for node in root.get_children():
		if node is LightOccluder2D:
			print("FOUND!")
			if node.occluder_light_mask == 1:
				static_occluders.append(node)
			if node.occluder_light_mask == 2:
				moving_occluders.append(node)
			
		_recursively_search_for_occluders(node)

func _remove_all_occluders(on):
	for node in on.get_children():
		if node is LightOccluder2D:
			node.free()
