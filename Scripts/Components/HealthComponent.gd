## A component to manage the health of an entity.
class_name HealthComponent
extends Node


@export var max_health: float = 100.0
@export var iframe_duration: float = 0.25 # In seconds

@onready var parent: Node = $"../"

var _health: float = max_health
var _iframes_active: bool = false

func take_damage(amount: float) -> void:
	if not _iframes_active:
		_health -= amount
		clampf(max_health, 0.0, max_health)
		iframes_on(iframe_duration)
		
		# Death
		if _health == 0:
			if parent.has_method("die"):
				parent.die()

func iframes_on(duration: float) -> void:
	_iframes_active = true
	await get_tree().create_timer(duration).timeout
	_iframes_active = false

# Setters and getters
func set_max_health(max_health: float) -> void:
	max_health = max_health

func set_iframe_duration(iframe_duration: float) -> void:
	iframe_duration = iframe_duration

func get_health() -> float:
	return _health
