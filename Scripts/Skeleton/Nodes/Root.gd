extends Node


@export var verbose_debug := false
@export var super_efficient := false
#controls the maximum fps to trigger the enabling of super efficient mode
@export var super_efficient_auto_enable_maximum:int
@export var brightness_modulate:CanvasModulate
@export_node_path("Node") var game_skeleton_node
@export_node_path("Control") var ui_root_node
@export_node_path("Node") var game_root_node
@export_node_path("TextureRect") var dialog_text_node
@export var KeyactionHandler:Node2D

func _ready():
	Global.root_node = self

	Global.game_skeleton_node = get_node(game_skeleton_node)
	Global.ui_root_node = get_node(ui_root_node)
	Global.game_root_node = get_node(game_root_node)
	Global.KeyactionHandler = KeyactionHandler
	Global.verbose_debug = verbose_debug
	Global.super_efficient = super_efficient
