class_name EnemySpawner
extends Node2D


@export var player_view_dist: int = 500
@export var enemy_close_dist: int = 2000
@export var draw_spawn_positions: bool
@export var enemy_list: Array[EnemySpawnerInfo]
@export var target_enemies_close: int = 1

var spawned_enemies: Array[Enemy]

func randomly_select_enemy() -> EnemySpawnerInfo:
	var rng := RandomNumberGenerator.new()
	var index_array: Array[int] = []
	for i in range(enemy_list.size()):
		for j in range(enemy_list[i].probability):
			index_array.append(i)
	
	return enemy_list[index_array[rng.randi_range(0, index_array.size() - 1)]]

func generate_spawn_positions() -> Array[SpawnInfo]:
	var rng := RandomNumberGenerator.new()
	var output: Array[SpawnInfo] = []
	var num_enemies_close := 0
	for enemy in spawned_enemies:
		var pos := enemy.global_position  
		var dist_squared := pos.distance_squared_to(Global.player.global_position)
		if dist_squared < enemy_close_dist ** 2:
			num_enemies_close += 1
	
	if num_enemies_close >= target_enemies_close:
		return []
	
	for i in range(target_enemies_close - num_enemies_close):
		var group: Array[SpawnInfo] = []
		var info = SpawnInfo.new()
		var random_enemy := randomly_select_enemy()
		info.scene = random_enemy.scene
		info.pos = Global.player.global_position + Util.random_vector(rng, enemy_close_dist, player_view_dist)
		if Util.do_pointcast(get_world_2d(), info.pos):
			continue
		group.append(info)
		output.append(info)
		
		for j in range(random_enemy.group_size - 1):
			var duplicated := SpawnInfo.new()
			duplicated.scene = random_enemy.scene
			duplicated.pos = info.pos + Util.random_vector(rng, 100, 400)
			if Util.do_pointcast(get_world_2d(), duplicated.pos):
				continue
			group.append(duplicated)
			output.append(duplicated)
		
		for item in group:
			item.group = group
	
	return output

func _process(delta: float) -> void:
	for enemy in spawned_enemies:
		if !is_instance_valid(enemy):
			spawned_enemies.remove_at(spawned_enemies.find(enemy))
	
	var spawn_positions := generate_spawn_positions()
	
	if spawn_positions.size() > 1:
		pass 
	
	var size := spawned_enemies.size()
	
	for item in spawn_positions:
		var enemy: Enemy = item.scene.instantiate()
		enemy.global_position = item.pos
		add_child(enemy)
		spawned_enemies.append(enemy)
		item.instance = enemy
	
	for i in range(spawn_positions.size()):
		var group: Array[Enemy] = []
		for item in spawn_positions[i].group:
			group.append(item.instance)
		if "group" in spawned_enemies[i + size]:
			spawned_enemies[i + size].group = group
	
	queue_redraw()
	
class SpawnInfo:
	var scene: PackedScene
	var pos: Vector2
	var group: Array[SpawnInfo] = []
	var instance: Enemy
