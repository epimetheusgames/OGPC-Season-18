class_name AnimatedEnemy
extends Enemy


var reached_target := false

func _ready() -> void:
	_enemy_ready()
	
	$FishNavigation.path_changed.connect(_path_changed)
	$FishNavigation.target_reached.connect(_target_reached)

func _path_changed():
	reached_target = false

func _target_reached():
	reached_target = true

func _process(delta: float) -> void:
	_process_enemy(delta)
	
	if player_in_area:
		_path_changed()
		
		$FishNavigation.target_position = closest_player.position
		if position.distance_to(closest_player.position) < settings.attack_distance && !$AttackBoxComponent.is_attacking:
			$AttackBoxComponent.attack()
			$FishAnimation.play("Attackd")
	
	if !reached_target:
		var target_position = $FishNavigation.get_next_path_position()
		velocity = (target_position - position).normalized()
		rotation = velocity.normalized().angle() + PI
		position += velocity * delta * 60
	
