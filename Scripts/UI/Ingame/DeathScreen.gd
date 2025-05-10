class_name DeathScreen
extends Control


@export var ingame_ui: Control
@export var vignette_shader: ColorRect
@export var title: Label

func _ready() -> void:
	Global.death_menu = self

func _process(_delta: float) -> void:
	if Global.player && Global.player.get_diver_health() <= 25:
		if vignette_shader:
			vignette_shader.material.set_shader_parameter("vignette_strength", 1.5)
		ingame_ui.visible = false
		get_tree().paused = true
		visible = true

func _on_restart_button_button_up() -> void:
	get_tree().paused = false
	Global.mission_system.restart_mission()
