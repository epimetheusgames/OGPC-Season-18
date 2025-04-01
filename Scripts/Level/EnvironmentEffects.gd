class_name EnvironmentEffects
extends Node

const master_bus: int = 0
const sfx_bus: int = 1
const music_bus: int = 2
const wind_bus: int = 3

func _process(_delta: float) -> void:
	var low_pass_effect: AudioEffectLowPassFilter = AudioServer.get_bus_effect(wind_bus, 0)
	low_pass_effect.cutoff_hz = 1500 - abs(Global.player.position.y) * 2

