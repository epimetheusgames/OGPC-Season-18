class_name MultiplayerBatchSyncComponent
extends BaseComponent


@export var batch_size: int = 50

@export var node_group_name: String = ""
@export var gd_sync_node_value_names: Array[String] = []

func _ready() -> void:
	component_name = "MultiplayerBatchSyncComponent"
	
	await get_tree().create_timer(3).timeout
	
	if Global.godot_steam_abstraction.is_lobby_owner:
		_sync()

func _sync():
	var i = 0
	while true:
		var node_list = get_tree().get_nodes_in_group(node_group_name)
		var node_size = node_list.size()
		
		if node_size == 0:
			await get_tree().create_timer(0.01).timeout
			continue
		
		if i > node_size - 1:
			i = 0
		
		for j in range(batch_size):
			for value in gd_sync_node_value_names:
				Global.godot_steam_abstraction.sync_var(node_list[i + j], value)
			
		i += batch_size
		
		await get_tree().create_timer(0.001).timeout
