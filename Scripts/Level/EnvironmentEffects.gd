class_name EnvironmentEffects
extends Node

var master_bus := AudioServer.get_bus_index("Master")
var sfx_bus := AudioServer.get_bus_index("SFX")
var music_bus := AudioServer.get_bus_index("Music")
var wind_bus := AudioServer.get_bus_index("Wind")

func _process(_delta: float) -> void:
	var low_pass_effect: AudioEffectLowPassFilter = AudioServer.get_bus_effect(wind_bus, 0)
	low_pass_effect.cutoff_hz = max(1500 - abs(Global.player.position.y) * 2, 50)
