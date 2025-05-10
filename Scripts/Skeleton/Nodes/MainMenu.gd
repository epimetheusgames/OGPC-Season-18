class_name MainMenu
extends Control


var playing_credits := false

func _ready():
	Global.chat = $MinimalChat
	Steam.lobby_match_list.connect(_lobby_list_updated)
	
	await get_tree().create_timer(0.1).timeout
	
	var save := Global.save_load_framework._load_global_config()
	$SoundMenu/MasterVolumeSlider.value = save.master_volume
	_on_master_volume_slider_value_changed(save.master_volume)
	$SoundMenu/MusicVolumeSlider.value = save.music_volume
	_on_music_volume_slider_value_changed(save.music_volume)
	$SoundMenu/SFXVolumeSlider.value = save.sfx_volume
	_on_sfx_volume_slider_value_changed(save.sfx_volume)
	
	$CreditsMenu/CreditsAnimationPlayer.play("MAIN")
	
	while true:
		await get_tree().create_timer(1).timeout
		Global.godot_steam_abstraction.get_lobby_list()

func _process(_delta: float) -> void:
	var members = Global.godot_steam_abstraction.lobby_members
	if Global.is_multiplayer:
		var text := "Members of lobby:\n"
		for member in members:
			text += member["steam_name"] + "\n"
		$Members.text = text
	
	if !Global.current_mission_node:
		Global.chat = $MinimalChat
	
	if Input.is_action_just_pressed("esc") && playing_credits:
		$CreditsMenu/CreditsAnimationPlayer.play("RESET")
		playing_credits = false

# Should be remotely called.
func set_multiplayer_status(status: String):
	$MultiplayerStatus.text = status

func _open_sound_button() -> void:
	$SoundButton.visible = false
	$CreditsButton.visible = false
	$BackButton.visible = false
	$SoundMenu.visible = true

func _lobby_list_updated(_lobbies: Array):
	var lobby_text := "Available lobbies:\n"
	for lobby in Global.godot_steam_abstraction.lobbies_list:
		if lobby[2] == "DivingGameLobby":
			lobby_text += "Lobby name: " + lobby[1] + " | Members: " + str(lobby[3])
	if !Global.is_multiplayer:
		$Members.text = lobby_text

func update_global_save() -> void:
	var save := GlobalSave.new()
	save.master_volume = $SoundMenu/MasterVolumeSlider.value
	save.music_volume = $SoundMenu/MusicVolumeSlider.value
	save.sfx_volume = $SoundMenu/SFXVolumeSlider.value
	Global.save_load_framework._save_global_config(save)

func _on_quit_button_button_up() -> void:
	if $StartButton.visible:
		get_tree().quit()
	elif $MultiplayerHostGameButton.visible:
		$MultiplayerHostGameButton.visible = false
		$LobbyNameInput.visible = false
		$MultiplayerHostButton.visible = true
		$MultiplayerJoinButton.visible = true
	elif $MultiplayerJoinGameButton.visible:
		$MultiplayerJoinGameButton.visible = false
		$LobbyNameInput.visible = false
		$MultiplayerHostButton.visible = true
		$MultiplayerJoinButton.visible = true
	elif $MultiplayerHostButton.visible:
		$MultiplayerHostButton.visible = false
		$MultiplayerJoinButton.visible = false
		$MultiplayerButton.visible = true
		$SingleplayerButton.visible = true
	elif $MultiplayerButton.visible:
		$MultiplayerButton.visible = false
		$SingleplayerButton.visible = false
		$StartButton.visible = true
		$QuitButton.text = "Quit"

func _on_start_button_button_up() -> void:
	$MultiplayerButton.visible = true
	$SingleplayerButton.visible = true
	$StartButton.visible = false
	$QuitButton.text = "Back"

func _on_singleplayer_button_button_up() -> void:
	$Sunlight.stop()
	$"../StaticBody2D/CollisionPolygon2D".disabled = true
	# Carsons code is straight doo doo
	#$"../StaticBody2D/CollisionPolygon2D2".disabled = true
	Global.ui_root_node.visible = false
	# The best solution is a fast one
	Global.brightness_modulate.visible = false
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
		$Sunlight.stop()
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

func _on_settings_button_up() -> void:
	$SoundButton.visible = true
	$CreditsButton.visible = true
	$BackButton.visible = true
	$StartButton.visible = false
	$SettingsButton.visible = false
	$QuitButton.visible = false
	$MultiplayerJoinButton.visible = false
	$MultiplayerButton.visible = false
	$SingleplayerButton.visible = false
	$MultiplayerHostButton.visible = false
	$MultiplayerJoinGameButton.visible = false
	$MultiplayerHostGameButton.visible = false
	$Members.visible = false

func _on_brightness_slider_value_changed(value: float) -> void:
	Global.set_brightness(value)
	update_global_save()

func _on_sound_button_button_up() -> void:
	$SoundMenu.visible = true
	$BackButton.visible = false
	$CreditsButton.visible = false
	$SoundButton.visible = false

func _on_sound_menu_back_button_button_up() -> void:
	$SoundMenu.visible = false
	$BackButton.visible = true
	$CreditsButton.visible = true
	$SoundButton.visible = true

func _on_back_button_button_up() -> void:
	$BackButton.visible = false
	$CreditsButton.visible = false
	$SoundButton.visible = false
	$StartButton.visible = true
	$SettingsButton.visible = true
	$QuitButton.visible = true
	$Members.visible = true

func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value / 100.0)
	update_global_save()

func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), value / 100.0)
	update_global_save()

func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), value / 100.0)
	update_global_save()

func _on_credits_button_button_up() -> void:
	$CreditsMenu/CreditsAnimationPlayer.play("CreditsAnimation")
	playing_credits = true
