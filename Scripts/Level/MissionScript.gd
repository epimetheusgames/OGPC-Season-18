class_name MissionRoot
extends Node2D

@export var canvas_modulate: CanvasModulate
@export var sun: DirectionalLight2D

var line_one_material
var line_two_material
var line_three_material
var line_four_material
var line_five_material
var line_six_materiald

var total_saved_civillians := 0

func _ready():
	Global.sun = sun
	
	# What the acrualy skib is this code
	var overlay_ui = CanvasLayer.new()
	overlay_ui.name = "overlay_ui"
	overlay_ui.follow_viewport_enabled = false 
	self.add_child(overlay_ui)
	if !Global.godot_steam_abstraction:
		return #????
	for x in get_parent().get_parent().get_node("GameUIOverlay").get_children().size():
		get_node("overlay_ui").add_child(get_parent().get_parent().get_node("GameUIOverlay").get_children()[x].duplicate())
	get_parent().get_parent().get_parent().get_node("UI").get_node("MainMenu").visible = false
	
	Global.game_time_system.pause_time = false
