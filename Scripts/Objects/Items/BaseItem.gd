class_name BaseItem
extends Area2D

@export var scene: PackedScene
@export var icon: Texture2D
@export var cost: int
@export var item_name: String

func _ready() -> void:
	collision_layer = 128
	collision_mask = 0

func generate_inventory_item() -> InventoryItem:
	var item := InventoryItem.new()
	item.name = item_name
	item.scene = scene
	item.icon = icon
	item.cost = cost
	return item
