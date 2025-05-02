## Selects one of it's child sounds and plays it at random.
## Only chooses a sound that has finished playing.
# Owned by: kaitaobenson

class_name AudioVariationPlayer
extends Node2D

@export var pitch_min: float = 1.0
@export var pitch_max: float = 1.0

@export var volume_min: float = 0.0
@export var volume_max: float = 0.0

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
		var audio_player: AudioStreamPlayer2D = audio_players[index]
		
		if audio_done_playing[index]:
			audio_player.pitch_scale = rng.randf_range(pitch_min, pitch_max)
			audio_player.volume_db = rng.randf_range(volume_min, volume_max)
			
			audio_player.play()
			audio_done_playing[index] = false
			break
		
		attempts += 1
	
	if delay_time > 0:
		delay_timer = delay_time
