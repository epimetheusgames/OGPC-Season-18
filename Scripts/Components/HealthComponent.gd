## A component to manage the health of an entity.
class_name HealthComponent
extends BaseComponent


@export var max_health: float = 100.0
@export var iframe_duration: float = 0.25 # In seconds

@onready var _health: float = max_health
var _iframes_active: bool = false


func _ready() -> void:
	component_name = "HealthComponent"
	
	_base_component_ready_post()

func take_damage(amount: float) -> void:
	if not _iframes_active:
		_health -= amount
		clampf(max_health, 0.0, max_health)
		iframes_on(iframe_duration)
		
		var parent = get_node(component_container)
		
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

func set_health(new_health: int) -> void:
	_health = new_health
