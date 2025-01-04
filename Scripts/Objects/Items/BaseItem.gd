class_name BaseItem
extends Area2D

@export var scene: PackedScene
@export var icon: Texture2D
@export var cost: int

func _ready() -> void:
	collision_layer = 128
	collision_mask = 0

func generate_inventory_item() -> InventoryItem:
	var item := InventoryItem.new()
	item.scene = scene
	item.icon = icon
	item.cost = cost
	return item
