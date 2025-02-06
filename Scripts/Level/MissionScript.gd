extends Node2D

var line_one_material
var line_two_material
var line_three_material
var line_four_material
var line_five_material
var line_six_material
func turn_on_efficient():
	if Global.super_efficient:
		$LevelContainer/Level/Waves/Line2D.material = null
		$LevelContainer/Level/Waves/Line2D2.material = null
		$LevelContainer/Level/Waves/Line2D3.material = null
		$LevelContainer/Level/Waves/Line2D4.material = null
		$LevelContainer/Level/Waves/Line2D5.material = null
		$LevelContainer/Level/Waves/Line2D6.material = null
		$LevelContainer/Level/Waves/Line2D7.material = null
		$LevelContainer/Level/OceanShader/Background.material = null
		$LevelContainer/Level/OceanShader/TransBackground.material = null
		$Shaders.visible = false
	
func _ready():
	#print_tree_pretty()
	
	if Global.current_mission:
		Global.current_mission.success_state_checker.initialize($LevelContainer/Level/MultiplayerPlayerSpawnerComponent/Diver)
	
	Global.current_mission_node = self
	if Global.super_efficient:
		$LevelContainer/Level/Waves/Line2D.material = null
		$LevelContainer/Level/Waves/Line2D2.material = null
		$LevelContainer/Level/Waves/Line2D3.material = null
		$LevelContainer/Level/Waves/Line2D4.material = null
		$LevelContainer/Level/Waves/Line2D5.material = null
		$LevelContainer/Level/Waves/Line2D6.material = null
		$LevelContainer/Level/Waves/Line2D7.material = null
		$LevelContainer/Level/OceanShader/Background.material = null
		$LevelContainer/Level/OceanShader/TransBackground.material = null
	
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
