## For being dead
extends State

var enemy: Enemy

func init() -> void:
	assert(parent is Enemy, "This state must have Enemy parent")
	enemy = parent

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
