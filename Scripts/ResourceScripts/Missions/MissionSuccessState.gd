class_name MissionSuccessStateChecker
extends Resource

@export var description: String
@export var success_type: Util.MissionSuccessType
@export_group("Type: Collect item")
@export var item_name: String
@export var item_count: int
@export_group("Type: Reach area")
@export var completion_area_name: String
@export_group("Type: Build")
@export var something: String

var diver: Diver

func initialize(diver: Diver) -> void:
	self.diver = diver

func check_success() -> bool:
	if !diver:
		diver = Global.player
		return false
	
	if success_type == Util.MissionSuccessType.ACQUIRE_ITEM:
		for item in diver.diver_inventory.inventory:
			if !item:
				continue
			if item.name == item_name && item.count >= item_count:
				return true
		return false
	if success_type == Util.MissionSuccessType.DISCOVER_AREA:
		for area in diver.diver_stats.completion_areas_entered:
			if area.name == completion_area_name:
				return true
		return false
	
	return false
