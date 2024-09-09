extends Node


var PORT: int = 6000
var IP_ADDRESS := "localhoast"
var MAX_CLIENTS: int = 4

var peers_connected: int = 0
var peer_ids_list: Array[int] = []

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)

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
func _create_client() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	Global.is_multiplayer = true

## Initialize server multiplayer peer
func _create_server() -> void:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT, MAX_CLIENTS)
	if error:
		print("ERROR: Creation of server was unsuccessful. This WILL cause errors.")
	multiplayer.multiplayer_peer = peer
	Global.is_multiplayer = true

func _terminate_networking() -> void:
	multiplayer.multiplayer_peer = null
	Global.is_multiplayer = false

func _on_peer_connected(id: int) -> void:
	peers_connected += 1
	peer_ids_list.append(id)
