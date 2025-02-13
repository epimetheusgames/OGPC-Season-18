class_name EnemySpawner
extends Node2D


@export var player_view_dist: int = 500
@export var enemy_close_dist: int = 2000
@export var draw_spawn_positions: bool
@export var enemy_list: Array[EnemySpawnerInfo]
@export var target_enemies_close: int = 3

var spawned_enemies: Array[Enemy]
var counter := 0

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
		if !is_instance_valid(enemy):
			continue
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
		info.node_name = str(counter)
		counter += 1
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
	if !Global.is_multiplayer_host() && Global.is_multiplayer:
		return
	
	var remove_indices: Array[int] = []
	for enemy in spawned_enemies:
		if !is_instance_valid(enemy):
			remove_indices.append(spawned_enemies.find(enemy))
	
	for i in remove_indices:
		spawned_enemies.remove_at(i)
	
	var spawn_positions := generate_spawn_positions()
	if len(spawn_positions) > 0:
		spawn_from_positions(spawn_positions)
		Global.godot_steam_abstraction.run_remote_function(self, "remote_spawn", [convert_to_remote(spawn_positions)])
	
	queue_redraw()
	
func remote_spawn(spawn_positions: Array[Dictionary]):
	var converted_info: Array[SpawnInfo]
	converted_info.resize(spawn_positions.size())
	
	var i := -1
	for item in spawn_positions:
		i += 1
		converted_info[i] = SpawnInfo.new()
		converted_info[i].scene = enemy_list[item["index"]].scene
		converted_info[i].pos = item["pos"]
		converted_info[i].node_name = item["name"]
	
	i = -1
	for item in spawn_positions:
		i += 1
		var converted_group: Array[SpawnInfo] = []
		for index in item["group_indices"]:
			converted_group.append(converted_info[index])
		converted_info[i].group = converted_group
	
	spawn_from_positions(converted_info)
	
func spawn_from_positions(spawn_positions: Array[SpawnInfo]):
	var size := spawned_enemies.size()
	
	for item in spawn_positions:
		var enemy: Enemy = item.scene.instantiate()
		enemy.global_position = item.pos
		enemy.name = item.node_name
		add_child(enemy, true)
		spawned_enemies.append(enemy)
		item.instance = enemy
	
	for i in range(spawn_positions.size()):
		var group: Array[Enemy] = []
		for item in spawn_positions[i].group:
			group.append(item.instance)
		if "group" in spawned_enemies[i + size]:
			spawned_enemies[i + size].group = group

func convert_to_remote(spawn_positions: Array[SpawnInfo]):
	var output: Array[Dictionary] = []
	for item in spawn_positions:
		var item_dict: Dictionary = {}
		item_dict["name"] = item.node_name
		item_dict["pos"] = item.pos
		item_dict["group_indices"] = []
		for member in item.group:
			item_dict["group_indices"].append(spawn_positions.find(member))
		var i: int = -1
		for enemy in enemy_list:
			i += 1
			if enemy.scene == item.scene:
				item_dict["index"] = i
		output.append(item_dict)
	return output

class SpawnInfo:
	var scene: PackedScene
	var pos: Vector2
	var group: Array[SpawnInfo] = []
	var instance: Enemy
	var node_name: String
