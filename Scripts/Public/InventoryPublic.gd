# Public functions for the diver's inventory. 
extends Node

@onready var inventory: DiverInventory = get_parent()

# For picking up items, where the index it will be placed in isn’t determined.
# Places it in the left-most valid index (stack up)
# Returns index it was placed in.  (-1 if no room)
# Uses nodes because you pick up nodes.
func add_item(new_item: BaseItem) -> int:
	inventory.__collect_item(new_item)
	for i in range(inventory.inventory.size()):
		if inventory.inventory[i].item.name == new_item.item_name:
			return i
	return -1

# Removes the item (turns to null)
# Same as set_item_at_index(index, null)
# Also moves items in front of the removed item backward.
func remove_item_at_index(index: int) -> void:
	inventory.inventory.remove_at(index)

# Gets the item, returns an item resource (not a node).
func get_item_at_index(index: int) -> InventoryItem:
	return inventory.inventory[index]

# Puts an item at specific index (For boxes to store stuff in)
func set_item_at_index(item: InventoryItem, index: int) -> void:
	inventory.inventory[index] = item

# For dropping items back into the world.
# If the index has more than one object, place down the object like bundled up.
# Position is global, where the item will be dropped to.
func drop_item(index: int, position: Vector2) -> void:
	var node = load(get_item_at_index(index).scene.file).instantiate()
	Global.player.get_parent().add_child(node)
	node.global_position = position

# Moving items in inventory.
# Can swap null item and valid item, that’s fine
# Uses get_item and set_item
func swap_items(index1: int, index2: int) -> void:
	var old_at_index1 := inventory.inventory[index1]
	inventory.inventory[index1] = inventory.inventory[index2]
	inventory.inventory[index2] = old_at_index1
