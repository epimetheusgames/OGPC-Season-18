# Owned by: carsonetb
extends GutTest

var root: Node
var slf: SaveLoadFramework
var game_container: Node

func before_all():
	root = load("res://Scenes/TSCN/Skeleton/Root.tscn").instantiate()
	slf = root.get_node("Skeleton/SaveLoadFramework")
	slf.exit_to_menu(6, GameSave.new())
	game_container = root.get_node("Game/GameContainer")

func test_levels():
	for level in slf.level_list:
		slf.load_level(level.file)
		
	
