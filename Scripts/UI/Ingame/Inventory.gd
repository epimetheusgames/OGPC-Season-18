class_name InventoryHUD
extends PanelContainer


@onready var slots: Array[BoxContainer] = [
	$MarginContainer/HBoxContainer/Slot1,
	$MarginContainer/HBoxContainer/Slot2,
	$MarginContainer/HBoxContainer/Slot3,
	$MarginContainer/HBoxContainer/Slot4,
]

func _process(delta: float) -> void:
	var i := 0
	for slot in Global.player.diver_inventory.inventory:
		if i > len(slots) - 1: 
			break
		slots[i].get_node("TextureRect").texture = slot.item.icon
		i += 1
