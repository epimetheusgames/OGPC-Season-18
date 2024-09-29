class_name BoidsGroup
extends Node


@export var num_boids: int = 0
@export_node_path("Node2D") var spawn_position_node_path
@export var spawn_variation: float = 10

func _ready():
	var boids_scene = Global.boids_calculator_node.boids_scene
	var rng := RandomNumberGenerator.new()
	var spawn_position: Node2D = get_node(spawn_position_node_path)
	
	for i in range(num_boids):
		var child: CharacterBody2D = boids_scene.instantiate()
		child.position = spawn_position.position + Vector2(rng.randf_range(-spawn_variation, spawn_variation), rng.randf_range(-spawn_variation, spawn_variation))
		add_child(child)
