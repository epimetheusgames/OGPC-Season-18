## For being dead
extends State


func enter() -> void:
	pass

func exit() -> void:
	pass

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	enemy.position += enemy.velocity * delta
	enemy.velocity *= 0.9 * delta * 60
	enemy.move_and_slide()
	return null
