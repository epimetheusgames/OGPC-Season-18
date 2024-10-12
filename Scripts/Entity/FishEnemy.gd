class_name AnimatedEnemy
extends Enemy

func _ready() -> void:
	_enemy_ready()
	
	$FishNavigation.path_changed.connect(_path_changed)
	$FishNavigation.navigation_finished.connect(_target_reached)
	
	$AttackBoxComponent.damage = settings.damage
	$HealthComponent.set_max_health(settings.health)
	$HealthComponent.set_health(settings.health)

func _path_changed():
	reached_target = false

func _target_reached():
	if wander_state == WANDER_MODE.WANDERING_TO_POINT:
		wander_state = WANDER_MODE.WANDER_POINT_REACHED
	
	reached_target = true

func _process(delta: float) -> void:
	_process_enemy(delta)
	
	if player_in_area:
		_path_changed()
		
		if position.distance_to(closest_player.position) < settings.attack_distance && !$AttackBoxComponent.is_attacking:
			$AttackBoxComponent.attack()
			$FishAnimation.play("Attack")
	
	if !reached_target:
		var target_position = $FishNavigation.get_next_path_position()
		velocity = (target_position - position).normalized()
		if player_in_area:
			velocity *= 1 + settings.agressiveness
		
		var target_angle := velocity.normalized().angle() + PI
		var angle_diff: float = angle_difference(rotation, target_angle)
		rotation += clamp(angle_diff * 0.05, -0.1, 0.1)
		
		position += velocity * delta * 60

func _on_pathfind_update_timer_timeout() -> void:
	$FishNavigation.target_position = target_position
