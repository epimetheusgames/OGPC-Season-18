class_name MainMenu
extends Control


func _ready():
	Global.chat = $MinimalChat
	Steam.lobby_match_list.connect(_lobby_list_updated)
	
	while true:
		await get_tree().create_timer(1).timeout
		Global.godot_steam_abstraction.get_lobby_list()

func _lobby_list_updated(lobbies: Array):
	var lobby_text := "Available lobbies:\n"
	for lobby in Global.godot_steam_abstraction.lobbies_list:
		if lobby[2] == "DivingGameLobby":
			lobby_text += "Lobby name: " + lobby[1] + " | Members: " + str(lobby[3])
	if !Global.is_multiplayer:
		$Members.text = lobby_text

func _on_quit_button_button_up() -> void:
	get_tree().quit()

func _on_start_button_button_up() -> void:
	$MultiplayerButton.visible = true
	$SingleplayerButton.visible = true
	$StartButton.visible = false

func _on_singleplayer_button_button_up() -> void:
	for child in $"../BoidsGroup".get_children():
		child.queue_free()
	$"../StaticBody2D/CollisionPolygon2D".disabled = true
	# Carsons code is straight doo doo
	#$"../StaticBody2D/CollisionPolygon2D2".disabled = true
	Global.ui_root_node.visible = false
	Global.save_load_framework.start_game(0) 

func _on_multiplayer_button_button_up() -> void:
	$MultiplayerButton.visible = false
	$SingleplayerButton.visible = false
	$MultiplayerJoinButton.visible = true
	$MultiplayerHostButton.visible = true

func _on_multiplayer_host_button_button_up() -> void:
	$MultiplayerJoinButton.visible = false
	$MultiplayerHostButton.visible = false
	$LobbyNameInput.visible = true
	$MultiplayerHostGameButton.visible = true

func _on_multiplayer_join_button_button_up() -> void:
	$MultiplayerJoinButton.visible = false
	$MultiplayerHostButton.visible = false
	$LobbyNameInput.visible = true
	$MultiplayerJoinGameButton.visible = true

func _on_multiplayer_host_game_button_button_up() -> void:
	if $MultiplayerHostGameButton.text == "Host":
		Global.godot_steam_abstraction.create_lobby($LobbyNameInput.text, "DivingGameLobby")
		$MultiplayerHostGameButton.disabled = true
		while true:
			await Global.godot_steam_abstraction.handshake_received
			set_multiplayer_status("Ready to start game.")
			Global.godot_steam_abstraction.run_remote_function(self, "set_multiplayer_status", ["Waiting for host to start the game."])
			
			# At this point at least one person has joined the lobby so we can allow the game to start.
			$MultiplayerHostGameButton.disabled = false
			$MultiplayerHostGameButton.text = "Start"
	else:
		Global.print_debug("Starting game.")
		for child in $"../BoidsGroup".get_children():
			child.queue_free()
		$"../StaticBody2D/CollisionPolygon2D".disabled = true
		$"../StaticBody2D/CollisionPolygon2D2".disabled = true
		Global.ui_root_node.visible = false
		Global.save_load_framework.start_game(0) 
		Global.godot_steam_abstraction.run_remote_function(Global.save_load_framework, "start_game_remote", [0])

func _on_multiplayer_join_game_button_button_up() -> void:
	Global.godot_steam_abstraction.join_lobby_by_name($LobbyNameInput.text)
	set_multiplayer_status("Waiting for host connection.")
	$MultiplayerJoinGameButton.disabled = true

func _process(delta: float) -> void:
	var members = Global.godot_steam_abstraction.lobby_members
	if Global.is_multiplayer:
		var text := "Members of lobby:\n"
		for member in members:
			text += member["steam_name"] + "\n"
		$Members.text = text
	
	if !Global.current_mission_node:
		Global.chat = $MinimalChat

# Should be remotely called.
func set_multiplayer_status(status: String):
	$MultiplayerStatus.text = status
