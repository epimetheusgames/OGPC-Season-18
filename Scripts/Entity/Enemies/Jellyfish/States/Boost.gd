## BOOST state for the jellyfish: boosts towards the player
extends State

@export var spin_state: State

const wait_time: float = 0.8
const boost_time: float = 5.0

var wait_timer: float
var boost_timer: float
var target_pos: Vector2

func enter() -> void:
	wait_timer = 0.0
	boost_timer = 0.0
	target_pos = enemy.get_diver_pos()

func exit() -> void:
	pass

func process_physics(delta: float) -> State:
	wait_timer += delta
	boost_timer += delta
	
	if wait_timer < wait_time:
		return null
	
	enemy = enemy as Jellyfish
	var dist: float = enemy.global_position.distance_to(target_pos)
	var boost_speed: float = min(dist * 0.9, 500) + 100
	
	enemy.boost(boost_speed, 3, target_pos)
	
	if boost_timer > boost_time || dist < 50:
		return spin_state
	
	return null
