extends PointLight2D

var min_energy := 0.3
var max_energy := 1.0
var speed := 7.0
var direction := 1.0

func _process(delta: float) -> void:
	# Update energy based on direction
	if direction > 0:
		energy = lerp(energy, max_energy, delta * speed)
	else:
		energy = lerp(energy, min_energy, delta * speed)
	
	# Reverse direction when close to target
	if direction > 0 and energy >= max_energy - 0.01:
		direction = -1.0
	elif direction < 0 and energy <= min_energy + 0.01:
		direction = 1.0
