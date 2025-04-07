class_name BaseItem
extends Area2D

@export var scene: FilePathResource
@export var icon: Texture2D
@export var cost: int
@export var item_name: String
@export var sellable_resource: bool = false
var ammount: int = 1

func _ready() -> void:
	collision_layer = 128
	collision_mask = 0

func generate_inventory_item() -> InventoryItem:
	var item := InventoryItem.new()
	item.name = item_name
	item.scene = scene
	item.icon = icon
	item.cost = cost
	item.count = ammount
	item.sellable_resource = sellable_resource
	return item
