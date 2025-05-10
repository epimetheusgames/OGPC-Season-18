## This is a big fish enemy
# Owned by: kaitaobenson


class_name Leviathan
extends Enemy

@export var LEVIATHAN_NODE: PackedScene

@export var node_amount: int = 100
@export var node_separation: float = 30.0

@onready var start_node: LeviathanNode = $"Head"
@onready var rope: FabrikRope = $"FabrikRope"

var leviathan_nodes: Array[LeviathanNode]
var nav_target: Vector2

func _ready() -> void:
	super()
	
	state_machine.init(self)
	
	# Set rope data
	rope.point_separation = node_separation
	rope.start_pos_on = true
	
	# Add in leviathan nodes
	leviathan_nodes.append(start_node)
	
	for i in range(rope.point_amount - 2):
		var new_node: LeviathanNode = LEVIATHAN_NODE.instantiate()
		
		add_child(new_node)
		leviathan_nodes.append(new_node)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	update_leviathan_nodes(delta)
	move_and_slide()
	
	if state_machine.current_state.name == "Chase" && $Head/AnimatedSprite2D.animation == "CloseMouth":
		$Head/AnimatedSprite2D.play("OpenMouth")
	if state_machine.current_state.name == "Wander" && $Head/AnimatedSprite2D.animation == "OpenMouth":
		$Head/AnimatedSprite2D.play("CloseMouth")
	
	if Global.is_multiplayer && has_multiplayer_sync && _is_node_owner():
		Global.godot_steam_abstraction.sync_var(rope, "points")

func update_leviathan_nodes(delta: float) -> void:
	rope.start_pos_on = true
	rope.start_pos = global_position
	
	var next_path_pos = nav_agent.get_next_path_position()
	
	for i in range(rope.point_amount - 1):
		leviathan_nodes[i].global_position = rope.points[i]
		if i == 0:
			leviathan_nodes[i].rotation = \
				Util.better_angle_lerp(
					leviathan_nodes[i].global_rotation, 
					rope.points[i].angle_to_point(next_path_pos), 
					0.2, delta)
		else:
			leviathan_nodes[i].global_rotation = rope.points[i].angle_to_point(rope.points[i - 1])
		
