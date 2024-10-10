extends Enemy

func _process(delta: float) -> void:
	_process_enemy(delta)
	
	if player_in_area:
		# If there is one player, go towards that.
		if num_players_in_area == 1:
			$FishNavigation.target_position = players_list[0].position
			
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
	
	var target_position = $FishNavigation.get_next_path_position()
	position += (target_position - position).normalized() * delta * 60
	
