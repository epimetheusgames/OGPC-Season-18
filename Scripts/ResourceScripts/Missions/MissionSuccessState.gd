class_name MissionSuccessStateChecker
extends Resource

@export var success_type: Util.MissionSuccessType
@export_category("Type: Collect item")
@export var item_name: String
@export var item_count: int
@export_category("Type: Reach area")
@export_category("Type: Build")

var diver: Diver

func initialize(diver: Diver) -> void:
	self.diver = diver

func check_success() -> bool:
	if !diver:
		diver = Global.player
		return false
	
	for item in diver.diver_inventory.inventory:
		if !item:
			continue
		if item.name == item_name && item.count >= item_count:
			return true
	return false
