## Component for an attackbox. When attack() is called other HurtboxComponents in the area will be notified.
# Owned by: carsonetb
class_name AttackBoxComponent
extends BaseHitboxComponent

@export var hitbox_type: HITBOX_TYPE
@export var damage := 1.0
@export var knockback_velocity := 5.0
@export var attack_seconds := 0.5
@export var always_attacking := false

var is_attacking := false

func _ready() -> void:
	_base_hitbox_ready()  # TODO: fix this
	super._ready_base_component()
	
	if hurtbox && !always_attacking:
		hurtbox_collision.disabled = true
		
		# Set to zero because we don't want to be detecting other AttackBoxes.
		hurtbox_node.collision_mask = 0
	
	if hitbox_type == HITBOX_TYPE.PLAYER:
		hurtbox_node.collision_layer = Global.bitmask_conversion["Player Attackbox / Enemy Hurtbox"]
	if hitbox_type == HITBOX_TYPE.ENEMY:
		hurtbox_node.collision_layer = Global.bitmask_conversion["Player Hurtbox / Enemy Attackbox"]
	if hitbox_type == HITBOX_TYPE.ENTITY_INTERACT:
		hurtbox_node.collision_layer = Global.bitmask_conversion["Interaction"]

func attack() -> void:
	if always_attacking || !hurtbox:
		print("WARNING: Cannot attack because AttackBox because either:")
		print("- AttackBox is set to always attacking OR")
		print("- AttackBox has no hurtbox node attached")
		return
	
	hurtbox_collision.disabled = false
	is_attacking = true
	
	await get_tree().create_timer(attack_seconds).timeout
	
	hurtbox_collision.disabled = true
	is_attacking = false
