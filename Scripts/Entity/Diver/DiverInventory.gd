# Diver inventory system.
class_name DiverInventory
extends Node2D

@export var inventory: Array[InventoryItem]
var hovering_item: Node2D
var hovering_resource: InventoryItem

#🤔
var hovering_item_item: BaseItem
@export var inventory_size := 4

var just_selected := false

func _process(delta: float) -> void:
	if hovering_item && is_instance_valid(hovering_item):
		hovering_item.global_position = get_global_mouse_position()
		if Input.is_action_just_released("mouse_left_click") && !just_selected:
			if hovering_resource.count <= 1:
				hovering_item.process_mode = Node.PROCESS_MODE_PAUSABLE
				hovering_item._ready()
				hovering_item = null 
			else:
				var duplicated_item := hovering_item.duplicate()
				duplicated_item.process_mode = Node.PROCESS_MODE_PAUSABLE
				Global.player.get_parent().add_child(duplicated_item)
				hovering_resource.count -= 1
				hovering_item_item.ammount -= 1
		elif Input.is_action_just_released("mouse_left_click"): 
			just_selected = false

func _on_item_detection_area_area_entered(area: Area2D) -> void:
	var hoverings_child: BaseItem 
	if hovering_item != null:
		hoverings_child = hovering_item_item
	if area is BaseItem && !area == hovering_item && !area == hoverings_child:
		__collect_item(area)

func __collect_item(area: BaseItem) -> void:
	var res: InventoryItem = area.generate_inventory_item()
	area.get_parent().queue_free()
	for item in inventory:
		if !item:
			continue
		if item.name == res.name:
			item.count += 1
			return
	if inventory.size() >= inventory_size:
		return
	inventory.append(res)
	if Global.verbose_debug:
		print("DEBUG: Item collected by player. Name: " + res.name + ". Cost: " + str(res.cost))

func __select_item(index: int) -> void:
	if index >= inventory.size():
		return
	
	if hovering_item:
		inventory[index] = hovering_resource
		hovering_item = null
		hovering_resource = null
		hovering_item_item = null
		return
	
	if !inventory[index]:
		return
		
	just_selected = true
	
	hovering_item = load(inventory[index].scene.file).instantiate()
	hovering_item.process_mode = Node.PROCESS_MODE_DISABLED
	Global.player.get_parent().add_child(hovering_item)
	hovering_resource = inventory[index]
	
	if hovering_item is BaseItem:
		hovering_item_item = hovering_item
	else:
		hovering_item_item = Util.find_all_children_of_type(hovering_item, "BaseItem")[0]
	
	inventory[index] = null
