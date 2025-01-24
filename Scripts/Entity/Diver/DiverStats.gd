class_name DiverStats
extends Node2D

var health: float
var oxygen_percentage: float = 100
var oxygen_loss: float

func _process(delta: float) -> void:
	oxygen_percentage -= oxygen_loss * delta * 60
