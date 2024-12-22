# Owned by: carsonetb
class_name AnimatedEnemy
extends Enemy

var _physics_velocity = Vector2.ZERO

func _ready() -> void:
	_enemy_ready()
	
	$FishNavigation.path_changed.connect(_path_changed)
	$FishNavigation.navigation_finished.connect(_target_reached)
	$HealthComponent.died.connect(_died)
	
	$AttackBoxComponent.damage = settings.damage
	$HealthComponent.set_max_health(settings.health)
	$HealthComponent.set_health(settings.health)

func _path_changed():
	reached_target = false

func _died():
	queue_free()

func _target_reached():
	if wander_state == WANDER_MODE.WANDERING_TO_POINT:
		wander_state = WANDER_MODE.WANDER_POINT_REACHED
	
	reached_target = true

func _process(delta: float) -> void:
	_enemy_process(delta)
	
	if player_visible:
		_path_changed()
		
		if position.distance_to(closest_player.position) < settings.attack_distance && !$AttackBoxComponent.is_attacking:
			$AttackBoxComponent.attack()
			$FishAnimation.play("Attack")
	
	var intended_velocity = velocity
	
	_physics_velocity /= 2.0
	
	if !reached_target:
		var target_path_position: Vector2 = $FishNavigation.get_next_path_position()
		var target_velocity := (target_path_position - position).normalized()
		
		if player_visible:
			target_velocity *= 1 + settings.agressiveness
		
		intended_velocity = Util.better_vec2_lerp(velocity, target_velocity, 0.09, delta)
		
		var target_angle := velocity.normalized().angle() + PI
		rotation = Util.better_angle_lerp(rotation, target_angle, 0.1, delta)
	
	$FishNavigation.set_velocity(intended_velocity)
	move_and_slide()
	if !(closest_player && (position.distance_to(closest_player.position) < settings.closest_distance)):
		position += velocity * delta * 60

func set_new_velocity(new_velocity: Vector2) -> void:
	_physics_velocity = new_velocity

func _on_pathfind_update_timer_timeout() -> void:
	$FishNavigation.target_position = target_position

func _on_fish_navigation_velocity_computed(safe_velocity: Vector2) -> void:
	if safe_velocity != Vector2.ZERO:
		velocity = safe_velocity + _physics_velocity
