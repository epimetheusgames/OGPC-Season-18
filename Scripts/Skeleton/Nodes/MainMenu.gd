class_name MainMenu
extends Control



func _on_quit_button_button_up() -> void:
	get_tree().quit()

func _on_start_button_button_up() -> void:
	# Peak oop
	Global.save_load_framework.start_game(0, Global.mission_system.default_mission_tree.missions[0]) 
