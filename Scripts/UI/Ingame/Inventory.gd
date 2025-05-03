# Diver inventory UI overlay. For interacting with the inventory see the node
# in the Diver scene.
class_name InventoryHUD
extends PanelContainer


@onready var slots: Array[BoxContainer] = [
	$MarginContainer/HBoxContainer/Slot1,
	$MarginContainer/HBoxContainer/Slot2,
	$MarginContainer/HBoxContainer/Slot3,
	$MarginContainer/HBoxContainer/Slot4,
]

func _process(_delta: float) -> void:
	var i := 0
	for slot in Global.player.diver_inventory.inventory:
		if !slot:
			continue
		if i > len(slots) - 1: 
			break
		slots[i].get_node("TextureRect").texture = slot.icon
		slots[i].get_node("Counter").text = str(slot.count)
		i += 1
	
	for j in range(i, slots.size()):
		slots[j].get_node("TextureRect").texture = null
		slots[j].get_node("Counter").text = ""

func _on_slot_button_button_down() -> void:
	Global.player.diver_inventory.__select_item(0)

func _on_slot_button_2_button_down() -> void:
	Global.player.diver_inventory.__select_item(1)

func _on_slot_button_3_button_down() -> void:
	Global.player.diver_inventory.__select_item(2)

func _on_slot_button_4_button_down() -> void:
	Global.player.diver_inventory.__select_item(3)
