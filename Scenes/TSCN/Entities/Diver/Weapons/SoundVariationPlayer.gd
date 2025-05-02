## Selects one of it's child sounds and plays it at random.
## Only chooses a sound that has finished playing.
# Owned by: kaitaobenson

class_name AudioVariationPlayer
extends Node2D

@export var pitch_variation: float = 0.1
@export var delay_time: float = 0.0

var rng := RandomNumberGenerator.new()

var audio_players: Array[AudioStreamPlayer2D] = []
var audio_done_playing: Array[bool] = []
var delay_timer: float = 0.0

func _ready() -> void:
	for child in get_children():
		if child is AudioStreamPlayer2D:
			audio_players.append(child)
			audio_done_playing.append(true)
			child.finished.connect(_on_audio_finished.bind(audio_players.size() - 1))

func _process(delta: float) -> void:
	if delay_timer > 0:
		delay_timer -= delta

func _on_audio_finished(index: int) -> void:
	audio_done_playing[index] = true

func play_random() -> void:
	if delay_timer > 0:
		return
	
	var attempts: int = 0
	
	while true:
		if attempts > 10:
			break
		
		var index = rng.randi_range(0, audio_players.size() - 1)
		
		if audio_done_playing[index]:
			audio_players[index].pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
			audio_players[index].play()
			audio_done_playing[index] = false
			break
		
		attempts += 1
	
	if delay_time > 0:
		delay_timer = delay_time
