class_name PlaceableBuildingItem
extends BaseItem

@export var building: PackedScene

func _ready() -> void:
	var new_building: PlaceableBuilding = building.instantiate()
	get_parent().add_child(new_building)
	queue_free()
