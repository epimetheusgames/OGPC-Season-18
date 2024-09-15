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
		hurtbox.disabled = true

func attack() -> void:
	if always_attacking || !hurtbox:
		return
	
	hurtbox.disabled = false
	is_attacking = true
	
	await get_tree().create_timer(attack_seconds).timeout
	
	hurtbox.disabled = true
	is_attacking = false
