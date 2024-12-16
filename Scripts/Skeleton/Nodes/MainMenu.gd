class_name MainMenu
extends Control



func _on_quit_button_button_up() -> void:
	get_tree().quit()


func _on_start_button_button_up() -> void:
	Global.save_load_framework.load_level("res://Scenes/TSCN/Levels/Missions/Mission1.tscn")
