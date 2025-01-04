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
		var new_slot := InventorySlot.new()
		new_slot.item = res
		new_slot.count = 1
		inventory.append(new_slot)
		if Global.verbose_debug:
			print("DEBUG: Item collected by player. Name: " + res.name + ". Cost: " + str(res.cost))

class InventorySlot:
	var item: InventoryItem
	var count: int
