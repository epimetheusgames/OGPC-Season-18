class_name Enemy
extends CharacterBody2D

@export var hurtbox: Hurtbox
@export var nav_agent: NavigationAgent2D

@export var drop_item: BaseItem

enum ENEMY_STATE {
	WANDER,
	CHASE,
	ESCAPE,
}

var enemy_state: ENEMY_STATE = ENEMY_STATE.WANDER

func _ready() -> void:
	pass

func _call_movement(delta: float) -> void:
	match enemy_state:
		ENEMY_STATE.WANDER:
			wander(delta)
		ENEMY_STATE.CHASE:
			chase(delta)
		ENEMY_STATE.ESCAPE:
			escape(delta)

# Override these movement functions
func wander(delta: float) -> void:
	pass

func chase(delta: float) -> void:
	pass

func escape(delta: float) -> void:
	pass
