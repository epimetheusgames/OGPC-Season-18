## Base class for all enemies
# Owned by: kaibenson

class_name Enemy
extends CharacterBody2D

@export var hurtbox: Hurtbox
@export var nav_agent: NavigationAgent2D
@export var enemy_fov: EnemyFov

@export var drop_item: BaseItem

enum EnemyState {
	WANDER,
	CHASE,
	ESCAPE,
}

#var EnemyState: EnemyState = EnemyState.WANDER

func _ready() -> void:
	pass

func _call_movement(delta: float) -> void:
	match EnemyState:
		EnemyState.WANDER:
			wander(delta)
		EnemyState.CHASE:
			chase(delta)
		EnemyState.ESCAPE:
			escape(delta)

# Override these movement functions
func wander(delta: float) -> void:
	pass

func chase(delta: float) -> void:
	pass

func escape(delta: float) -> void:
	pass
