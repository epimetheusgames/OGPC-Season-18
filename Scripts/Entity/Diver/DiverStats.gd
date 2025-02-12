class_name DiverStats
extends Node2D

var health: float = 100
var oxygen_percentage: float = 100
var oxygen_loss: float
var completion_areas_entered: Array[CompletionArea]
@onready var diver: Diver = get_parent()

func _process(delta: float) -> void:
	oxygen_percentage -= oxygen_loss * delta * 60

func _on_general_detection_box_area_entered(area: Area2D) -> void:
	if area is CompletionArea:
		completion_areas_entered.append(area)

func _on_general_detection_box_area_exited(area: Area2D) -> void:
	if area is CompletionArea:
		completion_areas_entered.remove_at(completion_areas_entered.find(area))
