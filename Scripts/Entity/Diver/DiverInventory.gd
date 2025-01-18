# Diver inventory system.
class_name DiverInventory
extends Node2D

var inventory: Array[InventorySlot]
var hovering_item: Node2D

func _process(delta: float) -> void:
	if hovering_item && is_instance_valid(hovering_item):
		hovering_item.global_position = get_global_mouse_position()
		if Input.is_action_just_pressed("mouse_left_click"):
			hovering_item = null 

func _on_item_detection_area_area_entered(area: Area2D) -> void:
	var hoverings_child: BaseItem
	if hovering_item:
		for child in hovering_item.get_children():
			if child is BaseItem:
				hoverings_child = child
				break
	if area is BaseItem && !area == hovering_item && !area == hoverings_child:
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

func select_item(index: int) -> void:
	if index >= inventory.size():
		return
	
	if hovering_item:
		hovering_item = null
		return
	
	hovering_item = load(inventory[index].item.scene.file).instantiate()
	Global.player.get_parent().add_child(hovering_item)
	
	if inventory[index].count == 1:
		inventory.remove_at(index)
	else:
		inventory[index].count -= 1

class InventorySlot:
	var item: InventoryItem
	var count: int
