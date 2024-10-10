## Base class for components which use a hitbox. Do not assign multiple CollisionShape2Ds as a child of the hurtbox.
class_name BaseHitboxComponent
extends BaseComponent


@export_node_path("Area2D") var hurtbox

var hurtbox_node: Area2D
var hurtbox_collision: CollisionShape2D

func _ready() -> void:
	component_name = "BaseHitboxComponent"

func _process(delta: float) -> void:
	if !hurtbox:
		print("WARNING: HitboxComponent at path " + str(get_path()) + " requires a hurtbox (Area2D) attached to it.")
		return

func _init_hurtbox() -> void:
	if hurtbox:
		hurtbox_node = get_node(hurtbox)
		hurtbox_collision = hurtbox_node.get_children()[0]
		
		# 2 = 0100 in binary (see collision mask dataset in GDSCRIPTRULES.md)
		hurtbox_node.collision_mask = 2
