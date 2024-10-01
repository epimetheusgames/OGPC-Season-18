class_name MultiplayerManager
extends Node


var PORT: int = 6000
var IP_ADDRESS := "127.0.0.1"
var MAX_CLIENTS: int = 4

var peers_connected: int = 0
var peer_ids_list: Array[int] = []

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	Global.multiplayer_manager = self
	
	# Tests for GD-Sync stun
	GDSync.connected.connect(_connected)
	GDSync.connection_failed.connect(_connection_failed)
	GDSync.lobby_created.connect(_lobby_created)
	GDSync.lobby_creation_failed.connect(_lobby_creation_failed)
	GDSync.lobby_joined.connect(_lobby_joined)
	GDSync.lobby_join_failed.connect(_lobby_join_failed)
	GDSync.client_joined.connect(_client_joined)
	
	GDSync.start_multiplayer()
	
	await GDSync.connected

# Creates a lobby and joins it.
func gd_sync_create_lobby(lobby_name: String, password: String):
	GDSync.create_lobby(lobby_name, password, true, 4)
	GDSync.join_lobby(lobby_name, password)
	Global.is_multiplayer = true

# Joins a lobby
func gd_sync_join_lobby(lobby_name: String, password: String):
	GDSync.join_lobby(lobby_name, password)
	Global.is_multiplayer = true

# Exits the current lobby regardless of platform.
func exit_lobby():
	GDSync.leave_lobby()
	Global.is_multiplayer = false

func _client_joined(client_id: int) -> void:
	print("Client with id " + str(client_id) + " has joined GD-Sync lobby.")
	peers_connected += 1
	peer_ids_list.append(client_id)

func _connected():
	print("Connected to GD-Sync servers.")

func _connection_failed(error: int):
	match(error):
		ENUMS.CONNECTION_FAILED.INVALID_PUBLIC_KEY:
			push_error("The public or private key you entered were invalid.")
		ENUMS.CONNECTION_FAILED.TIMEOUT:
			push_error("Unable to connect, please check your internet connection.")

func _lobby_created(lobby_name: String):
	print("Created GD-Sync lobby " + lobby_name)

func _lobby_creation_failed(lobby_name: String, error: int):
	print("Error creating GD-Sync lobby " + lobby_name + ", error code " + str(error))

func _lobby_joined(lobby_name: String):
	print("Joined GD-Sync lobby " + lobby_name)

func _lobby_join_failed(lobby_name : String, error : int):
	match(error):
		ENUMS.LOBBY_JOIN_ERROR.LOBBY_DOES_NOT_EXIST:
			push_error("The lobby "+lobby_name+" does not exist.")
		ENUMS.LOBBY_JOIN_ERROR.LOBBY_IS_CLOSED:
			push_error("The lobby "+lobby_name+" is closed.")
		ENUMS.LOBBY_JOIN_ERROR.LOBBY_IS_FULL:
			push_error("The lobby "+lobby_name+" is full.")
		ENUMS.LOBBY_JOIN_ERROR.INCORRECT_PASSWORD:
			push_error("The password for lobby "+lobby_name+" was incorrect.")
		ENUMS.LOBBY_JOIN_ERROR.DUPLICATE_USERNAME:
			push_error("The lobby "+lobby_name+" already contains your username.")
	  

@rpc("call_local", "reliable")
func load_level(multiplayer_level_path: String) -> void:
	var game_root: Node = get_parent().get_parent().get_node("Game")
	game_root.add_child(load(multiplayer_level_path).instantiate())

@rpc("call_local", "reliable")
func exit_to_menu() -> void:
	var game_root: Node = get_parent().get_parent().get_node("Game")
	for child in game_root.get_children():
		child.queue_free()

## Initialize client multiplayer peer
func _local_network_create_client() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	Global.is_multiplayer = true

## Initialize server multiplayer peer
func _local_network_create_server() -> void:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT, MAX_CLIENTS)
	if error:
		print("ERROR: Creation of server was unsuccessful. This WILL cause errors.")
	multiplayer.multiplayer_peer = peer
	Global.is_multiplayer = true

func _terminate_networking() -> void:
	var multiplayer_type := Global.get_multiplayer_type()
	if multiplayer_type == Global.MULTIPLAYER_MODE.LOCAL_NETWORK:
		multiplayer.multiplayer_peer = null
	if multiplayer_type == Global.MULTIPLAYER_MODE.GD_SYNC:
		exit_lobby()
		GDSync.stop_multiplayer()
	
	Global.is_multiplayer = false

func _on_peer_connected(id: int) -> void:
	peers_connected += 1
	peer_ids_list.append(id)
