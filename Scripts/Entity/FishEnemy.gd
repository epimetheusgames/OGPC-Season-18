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
	
	if velocity.x < 0:
		scale.x = 5
	else:
		scale.x = -5
	
	if player_in_area:
		_path_changed()
		
		# If there is one player, go towards that.
		if num_players_in_area == 1:
			$FishNavigation.target_position = players_list[0].position
			
			if position.distance_to(players_list[0].position) < settings.attack_distance && !$AttackBoxComponent.is_attacking:
				$AttackBoxComponent.attack()
				$FishAnimation.play("Attack")
			
		# Else find the closest player
		else:
			var closest_dist := 99999999
			var closest_ind := 0
			for i in range(players_list.size()):
				var distance: int = position.distance_to(players_list[i].position)
				if distance < closest_dist:
					closest_dist = distance
					closest_ind = i
			
			$FishNavigation.target_position = players_list[closest_ind].position
			
			if closest_dist < settings.attack_distance && !$AttackBoxComponent.is_attacking:
				$AttackBoxComponent.attack()
				$FishAnimation.play("Idle")
	
	if !reached_target:
		var target_position = $FishNavigation.get_next_path_position()
		velocity = (target_position - position).normalized()
		position += velocity * delta * 60
	
