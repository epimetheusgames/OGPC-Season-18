## Knife with a blunt tip so that you don't accidentally 
## Poke ur suit
# Owned by: kaitaobenson

class_name BluntTipKnife
extends Knife

@onready var swoosh_sounds: AudioVariationPlayer = $"SwooshSounds"

func perform_attack(remote=false, node_name="") -> void:
	swoosh_sounds.play_random()
