class_name ChatPanel
extends MinimalChat

@export var teleport_place_names: Array[String]
@export var teleport_places: Array[Node2D]
@export var enemy_spawn_names: Array[String]
@export var enemy_scenes: Array[FilePathResource]
@export var enemy_root: Node2D

var typing_command_override := false


func _ready() -> void:
	text = $MarginContainer/VBox/RichTextLabel
	line_edit = $MarginContainer/VBox/LineEdit
	Global.chat = self

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("command"):
		line_edit.grab_focus.call_deferred()
		line_edit.text = "/"
		line_edit.caret_column = 1
		typing_command_override = true
	if Input.is_action_just_pressed("esc"):
		line_edit.release_focus()
		typing_command_override = false
		line_edit.text = ""

	if !Global.is_multiplayer && !typing_command_override:
		visible = false
	else:
		visible = true

# Pares message, it is a command if it starts with /, otherwise put it in the chat.
func _on_line_edit_text_submitted(new_text: String) -> void:
	line_edit.text = ""
	if new_text.begins_with("/"):
		var command:= new_text.split(" ")

		# Commands include:
		# /help - Display all commands.
		# /goto <place> - Teleport to a place.
		# /spawn <entity> - Spawn an entity.
		# /killall - Kills all enemies.
		# /goto-player <player> - Teleport to the player.
		# /exit - Exit to main menu
		match command[0]:
			"/help":
				push_chat("System", "Commands:", "green", "white")
				push_chat("System", "/help - Display all commands.", "green", "white")
				push_chat("System", "/goto <place> - Teleport to a place.", "green", "white")
				push_chat("System", "/spawn <entity> - Spawn an entity.", "green", "white")
				push_chat("System", "/goto-player <player> - Teleport to the player.", "green", "white")
				push_chat("System", "/exit - Exit to main menu", "green", "white")
			"/goto":
				if command.size() > 1:
					for i in range(teleport_place_names.size()):
						if teleport_place_names[i] == command[1]:
							Global.player.global_position = teleport_places[i].global_position
							return
					push_error("ERROR: Place " + command[1] + " not found.")
				else:
					push_error("ERROR: No place specified.")
			"/spawn":
				if command.size() > 1:
					for i in range(enemy_spawn_names.size()):
						if enemy_spawn_names[i] == command[1]:
							var enemy_scene: PackedScene = load(enemy_scenes[i].file)
							var enemy: Enemy = enemy_scene.instantiate()
							enemy.global_position = Global.player.global_position
							enemy_root.add_child(enemy)
							return
					push_error("ERROR: Enemy " + command[1] + " not found.")
				else:
					push_error("ERROR: No entity specified.")
			"/goto-player":
				if command.size() > 1:
					for player in Global.players:
						if player.name == command[1]:
							Global.player.global_position = player.global_position
							return
					push_error("ERROR: Player " + command[1] + " not found.")
				else:
					push_error("ERROR: No player specified.")
			"/exit":
				Global.save_load_framework.exit_to_menu()
			_:
				push_error("ERROR: Command " + command[0] + " not found.")
	else:
		push_chat(Global.player.name, new_text, "white", "white")

