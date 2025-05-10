# Diver inventory system.
class_name DiverInventory
extends Node2D

@export var inventory: Array[InventoryItem]
var hovering_item: Node2D
var hovering_resource: InventoryItem
@onready var diver: Diver = get_parent()
@export var default_placeable_building: PackedScene

#🤔
var hovering_item_item: BaseItem
@export var inventory_size := 4

var just_selected := false
var collecting_money := false

## Relative to mission root, saved, so they can be deleted.
var collected_item_paths: Array[NodePath]

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	
	for path in collected_item_paths:
		var item: BaseItem = Global.current_mission_node.get_node_or_null(path)
		if !item:
			continue
		item.queue_free()

func _process(delta: float) -> void:
	if !diver._is_node_owner():
		return
	
	# Clean up inventory
	for item in inventory:
		if !is_instance_valid(item) || !item:
			inventory.remove_at(inventory.find(item))
	
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
	
	# Sell items automatically, there should be an animation for this.
	if diver.diver_movement.is_in_research_station && !collecting_money:
		var income := 0
		for item in inventory:
			if !is_instance_valid(item) || !item:
				continue
			if item.sellable_resource:
				income += item.cost * item.count
				inventory.remove_at(inventory.find(item))
		if income > 1:
			diver.diver_animation.animate_collected_item(income)
			collecting_money = true
			
			await get_tree().create_timer(2.5).timeout
			
			diver.diver_stats.current_money += income
			
			for player in Global.player_array:
				player.diver_stats.current_money = diver.diver_stats.current_money
				Global.godot_steam_abstraction.sync_var(player.diver_stats, "current_money")
			
			collecting_money = false

func _on_item_detection_area_area_entered(area: Area2D) -> void:
	if !diver._is_node_owner():
		return
	
	var hoverings_child: BaseItem 
	if hovering_item != null:
		hoverings_child = hovering_item_item
	if area is BaseItem && !area == hovering_item && !area == hoverings_child:
		__collect_item(area)

func __collect_item(area: BaseItem) -> void:
	if !diver._is_node_owner():
		return
	
	var res: InventoryItem = area.generate_inventory_item()
	collected_item_paths.append(Global.current_mission_node.get_path_to(area))
	area.queue_free()
	for item in inventory:
		if !item:
			continue
		if item.name == res.name:
			item.count += 1
			return
	if inventory.size() >= inventory_size:
		return
	inventory.append(res)
	Global.print_debug("DEBUG: Item collected by player. Name: " + res.name + ". Cost: " + str(res.cost))

func spawn_building(building_name: String) -> void:
	var node: PlaceableBuilding = default_placeable_building.instantiate()
	node.name = building_name
	node.placed_remotely = true
	Global.player.get_parent().add_child(node, true)

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
	
	if hovering_resource.name == "Building" && hovering_resource.count > 1:
		hovering_resource.count -= 1
		hovering_resource = hovering_resource.duplicate()
	else: 
		inventory[index] = null
