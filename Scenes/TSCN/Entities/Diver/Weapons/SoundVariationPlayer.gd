## Selects one of it's child sounds and plays it at random.
## Only chooses a sound that has finished playing.
# Owned by: kaitaobenson

class_name AudioVariationPlayer
extends Node2D

@export var pitch_variation: float = 0.5

var audio_players: Array[AudioStreamPlayer2D] = []
var audio_done_playing: Array[bool] = []

func _ready() -> void:
	for child in get_children():
		if child is AudioStreamPlayer2D:
			audio_players.append(child)
			audio_done_playing.append(true)
			child.finished.connect(_on_audio_finished.bind(audio_players.size() - 1))

func _on_audio_finished(index: int) -> void:
	audio_done_playing[index] = true

func play_random() -> void:
	while true:
		var index = randi_range(0, audio_players.size() - 1)
		if audio_done_playing[index]:
			audio_players[index].pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
			audio_players[index].play()
			audio_done_playing[index] = false
			break
