## Base class for components which use a hitbox. Do not assign multiple CollisionShape2Ds as a child of the hurtbox.
## This shouldn't be used on its own as it doesn't really have any functionality by itself ... use a child of it 
## instead.
# Owned by: carsonetb
class_name BaseHitboxComponent
extends BaseComponent


@export_node_path("Area2D") var hurtbox

var hurtbox_node: Area2D
var hurtbox_collision: CollisionShape2D
var collision_bitmask := 0

enum HITBOX_TYPE {PLAYER, ENEMY, ENTITY_INTERACT}

func _ready() -> void:
	_base_hitbox_ready()

func _process(delta: float) -> void:
	if !hurtbox:
		print("WARNING: HitboxComponent at path " + str(get_path()) + " requires a hurtbox (Area2D) attached to it.")
		return

func _base_hitbox_ready() -> void:
	_ready_base_component()
	if hurtbox:
		hurtbox_node = get_node(hurtbox)
		hurtbox_collision = hurtbox_node.get_children()[0]
		
		# 2 = 0100 in binary (see collision mask dataset in GDSCRIPTRULES.md)
		hurtbox_node.collision_mask = 2
		hurtbox_node.collision_layer = 2
