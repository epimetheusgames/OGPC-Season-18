class_name MultiplayerBatchSyncComponent
extends BaseComponent


@export var gd_sync_batch_size: int = 50
@export var local_network_batch_size: int = 500

@export var node_group_name: String = ""
@export var gd_sync_node_value_names: Array[String] = []
@export var local_network_node_rpc_function_names: Array[String] = []
@export var local_network_node_rpc_function_values: Array[PackedStringArray] = []

func _ready() -> void:
	component_name = "MultiplayerBatchSyncComponent"
	
	if Global.is_multiplayer_host():
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
		
		if Global.get_multiplayer_type() == Global.MULTIPLAYER_MODE.GD_SYNC:
			for j in range(gd_sync_batch_size):
				for value in gd_sync_node_value_names:
					GDSync.sync_var(node_list[i + j], value, false)
				
			i += gd_sync_batch_size
		if Global.get_multiplayer_type() == Global.MULTIPLAYER_MODE.LOCAL_NETWORK:
			for j in range(local_network_batch_size):
				for function in range(local_network_node_rpc_function_names.size()):
					var variable_array = []
					for item in local_network_node_rpc_function_values[function]:
						variable_array.append(node_list[i + j].get(item))
					
					node_list[i + j].get(local_network_node_rpc_function_names[function]).rpc.callv(variable_array)
		
			i += local_network_batch_size
		
		await get_tree().create_timer(0.001).timeout
