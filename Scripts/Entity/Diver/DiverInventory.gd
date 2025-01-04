# Diver inventory system.
class_name DiverInventory
extends Node2D

var inventory: Array[InventorySlot]

func _on_item_detection_area_area_entered(area: Area2D) -> void:
	if area is BaseItem:
		var res: InventoryItem = area.generate_inventory_item()
		area.get_parent().queue_free()
		for item in inventory:
			if item.item.name == res.name:
				item.count += 1
				return
		inventory.append(res)

class InventorySlot:
	var item: InventoryItem
	var count: int
