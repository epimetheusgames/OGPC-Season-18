## A component to manage the health of an entity.
# Owned by: kaitaobenson

class_name HealthComponent
extends BaseComponent


@export var max_health: float = 100.0
@export var iframe_duration: float = 0.25 # In seconds

@onready var _health: float = max_health
var _iframes_active: bool = false

signal damage_taken(health)
signal died

func _ready() -> void:
	_ready_health()

func _ready_health() -> void:
	component_name = "HealthComponent"
	_ready_base_component()

func take_damage(amount: float) -> void:
	if not _iframes_active:
		_health -= amount
		clampf(max_health, 0.0, max_health)
		iframes_on(iframe_duration)
		
		damage_taken.emit(_health)
		
		# Death
		if _health == 0:
			died.emit()

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

func set_health(new_health: int) -> void:
	if new_health > max_health:
		_health = max_health
	else:
		_health = new_health
