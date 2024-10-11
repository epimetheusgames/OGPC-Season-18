## Component for an attackbox. When attack() is called other HurtboxComponents in the area will be notified.
class_name AttackBoxComponent
extends BaseHitboxComponent

@export var damage := 1.0
@export var attack_seconds := 0.5
@export var always_attacking := false

var is_attacking := false

func _ready() -> void:
	_init_hurtbox()
	component_name = "AttackBoxComponent"
	
	if hurtbox && !always_attacking:
		hurtbox_collision.disabled = true
		
		# Set to zero because we don't want to be detecting other AttackBoxes.
		hurtbox_node.collision_mask = 0

func attack() -> void:
	if always_attacking || !hurtbox:
		print("WARNING: Cannot attack because AttackBox because either:")
		print("- AttackBox is set to allways attacking OR")
		print("- AttackBox has no hurtbox node attached")
		return
	
	hurtbox_collision.disabled = false
	is_attacking = true
	
	await get_tree().create_timer(attack_seconds).timeout
	
	hurtbox_collision.disabled = true
	is_attacking = false
