class_name EnvironmentEffects
extends Node

enum Playing {
	HAPPY,
	SCARY,
	SUBMARINE,
}

var playing: Playing = Playing.SUBMARINE

var master_bus := AudioServer.get_bus_index("Master")
var sfx_bus := AudioServer.get_bus_index("SFX")
var music_bus := AudioServer.get_bus_index("Music")

@onready var animator: AnimationPlayer = $MusicFade

func _ready() -> void:
	animator.play("RESET")

func _process(delta: float) -> void:
	if !Global.player.diver_movement.is_in_gravity_area && playing == Playing.SUBMARINE:
		animator.play("SubmarineToHappy")
		playing = Playing.HAPPY
	if (Global.player.get_oxygen() < 55 || Global.player.get_diver_health() < 40) && playing == Playing.HAPPY:
		animator.play("HappyToScary")
		playing = Playing.SCARY
	if Global.player.diver_movement.is_in_gravity_area && playing == Playing.HAPPY:
		animator.play("HappyToSubmarine")
		playing = Playing.SUBMARINE
	if Global.player.diver_movement.is_in_gravity_area && playing == Playing.SCARY:
		animator.play("ScaryToSubmarine")
		playing = Playing.SUBMARINE
