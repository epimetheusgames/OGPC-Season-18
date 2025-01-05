# This script automatically fades between two repeating textures on the inside
# and edges of the polygon.
# Owned by: carsonetb
@tool
class_name AutoPolygonTexture
extends Polygon2D

@export var child_of_navigation := false
@export var smooth_mesh := false
@export var move_collision_to: Node2D

var collision_object: StaticBody2D
var collision_polygon: CollisionPolygon2D
var occluder: LightOccluder2D

@onready var preloaded_shader_material: Resource = preload("res://Scenes/Resource/Level/AutoPolygonTextureMaterial.tres")
@export var no_shader := false

func _ready() -> void:
	_make_sure_nodes_instantiated()
	
	if child_of_navigation:
		get_parent().visible = true
	
	if smooth_mesh && !Engine.is_editor_hint():
		polygon = Util.smooth_line(polygon, 2)
		if child_of_navigation:
			get_parent().bake_navigation_polygon()
	
	if move_collision_to && !Engine.is_editor_hint():
		var collision_pos = collision_object.global_position
		remove_child(collision_object)
		move_collision_to.add_child.call_deferred(collision_object)
		collision_object.global_position = collision_pos
	
	collision_polygon.polygon = polygon
	occluder.occluder.polygon = polygon
	
	# Set all positions to zero which will cause them to be the same position
	# as the root Polygon2D (they are our children).
	collision_polygon.position = Vector2.ZERO
	collision_object.position = Vector2.ZERO
	occluder.position = Vector2.ZERO

func _process(delta: float) -> void:
	if !Engine.is_editor_hint() && Global.super_efficient:
		material = null
		return
	
	_make_sure_nodes_instantiated()
	
	if !no_shader:
		# Update shader parameters.
		material.set_shader_parameter("points", polygon)
		material.set_shader_parameter("num_points", polygon.size())
		material.set_shader_parameter("global_position", global_position)

# Check if neccesary children exist. If they don't, that means this node
# wasn't instantiated as a scene, this script was instantiated from the 
# add node dialog.
func _make_sure_nodes_instantiated() -> void:
	# Check if Collision node exists, if not instantiate it.
	if !collision_object || !collision_polygon:
		collision_object = StaticBody2D.new()
		collision_object.name = "Collision"
		collision_object.collision_mask = 129 # 10000001
		
		collision_polygon = CollisionPolygon2D.new()
		collision_polygon.name = "Polygon"
		collision_polygon.visible = false
		
		add_child(collision_object, true)
		collision_object.add_child(collision_polygon, true)
		collision_polygon.owner = collision_object
		
		collision_object.owner = self
		collision_polygon.owner = collision_object
	
	# Check if LightOccluder node exists, if not instantiate it.
	if !occluder:
		occluder = LightOccluder2D.new()
		occluder.name = "LightOccluder"
		occluder.visible = false
		
		var new_occluder_polygon = OccluderPolygon2D.new()
		occluder.occluder = new_occluder_polygon
	
		add_child(occluder)
		occluder.owner = self
	
	# Check if our shader material is setup. If not, instantiate a new one.
	if !material && !no_shader:
		material = preloaded_shader_material.duplicate(true)
	
