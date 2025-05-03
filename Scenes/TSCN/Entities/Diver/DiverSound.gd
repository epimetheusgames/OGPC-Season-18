class_name DiverSound
extends Node2D

@onready var diver: Diver = get_parent()

@onready var footstep_sounds: AudioVariationPlayer = $"FootstepSounds"
@onready var damage_sounds: AudioVariationPlayer = $"DamageSounds"
@onready var bubble_sounds: AudioStreamPlayer2D = $"BubbleSounds"

func _ready() -> void:
	diver = get_parent()
	$"../Stats/Hurtbox".damaged.connect(play_damage_sound)

func play_damage_sound(_amount: float, _by: Attackbox) -> void:
	damage_sounds.play_random()
