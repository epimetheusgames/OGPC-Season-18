# Owned by: carsonetb
class_name MultiplayerPlayerSpawnerComponent
extends BaseComponent


@export_file() var spawn_filepath: String 

func _ready() -> void:
	_ready_multiplayer_player_spawner()

func _ready_multiplayer_player_spawner() -> void:
	_ready_base_component()
	if Global.godot_steam_abstraction:
		Global.godot_steam_abstraction.user_joined_lobby.connect(_client_joined)
	
	if !Global.godot_steam_abstraction:
		return
	
	for client in Global.godot_steam_abstraction.lobby_members:
		_client_joined(client["steam_id"], client["steam_name"])

func _client_joined(client_id: int, client_name: String):
	Global.print_debug("DEBUG: Client joined with id " + str(client_id) + " and name " + client_name)
	
	if get_node_or_null(str(client_id)):
		print("WARNING: Player spawner component trying to spawn new player but player already exists.")
		return
	
	var client_player := _get_player_node(client_id)
	
	if client_id == Global.godot_steam_abstraction.steam_id:
		$Diver.node_owner = client_id
		$Diver.name = str(client_id)
		return
	
	add_child(client_player)
	client_player.node_owner = client_id
	
func _get_player_node(id: int) -> Entity:
	var client_player: Entity = load(spawn_filepath).instantiate()
	client_player.name = str(id)
	return client_player
