class_name Spear
extends RigidBody2D

@onready var spearhead_area: Area2D = $"SpearheadArea"

var attach_dif: Vector2 = Vector2.ZERO
var attach_body: Node2D = null
var attached: bool = false

func _ready() -> void:
	top_level = true

func _process(delta: float) -> void:
	if attached and attach_body:
		global_position = attach_body.to_global(attach_dif)
		global_rotation = attach_body.global_position.angle_to_point(global_position)

func _on_spearhead_area_body_entered(body: Node2D) -> void:
	print("skib")
	if attached or body is Spear:
		return
	
	attach_body = body as Node2D
	if attach_body:
		attached = true
		attach_dif = attach_body.to_local(global_position)
		freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
		print("Spear attached to:", attach_body.name)

func move_forwards(power: float) -> void:
	if not attached:
		linear_velocity = Vector2(power, 0).rotated(global_rotation)
