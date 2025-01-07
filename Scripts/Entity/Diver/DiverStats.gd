class_name DiverStats
extends Node2D

var max_health: float
var health: float
var oxygen_percentage: float = 100
var oxygen_loss: float

@onready var health_component: HealthComponent = $HealthComponent

func _process(delta: float) -> void:
	health = health_component.get_health()
	oxygen_percentage -= oxygen_loss * delta * 60

func set_health(new_health: float) -> void:
	health_component.set_health(new_health)

func get_health() -> float:
	return health_component.get_health()

func set_max_health(new_max: float) -> void:
	max_health = new_max
	health_component.set_max_health(new_max)

func get_max_health() -> float:
	return health_component.max_health
