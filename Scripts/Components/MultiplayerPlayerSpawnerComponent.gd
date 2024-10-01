class_name MultiplayerPlayerSpawnerComponent
extends BaseComponent


@export_file() var spawn_filepath: String 

func _ready() -> void:
	component_name = "MultiplayerPlayerSpawnerComponent"
	GDSync.client_joined.connect(_client_joined)
	# Figure out how to connect local signal later ...

func _client_joined(client_id: int):
	print("DEBUG: Spawning player with client id " + str(client_id))
	var client_player := _get_player_node(client_id)
	
	add_child(client_player)
	GDSync.set_gdsync_owner(client_player, client_id)
	
func _local_client_joined(id: int):
	var client_player := _get_player_node(id)
	add_child(client_player)
	client_player.set_multiplayer_authority(id)
	
func _get_player_node(id: int) -> CharacterBody2D:
	var client_player: CharacterBody2D = load(spawn_filepath).instantiate()
	client_player.name = str(id)
	return client_player
