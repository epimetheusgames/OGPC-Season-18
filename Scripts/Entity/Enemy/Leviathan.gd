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
	
	# Set rope data
	rope.point_amount = node_amount
	rope.point_separation = node_separation
	rope.start_pos_on = true
	
	# Add in leviathan nodes
	leviathan_nodes.append(start_node)
	
	for i in range(rope.point_amount - 2):
		var new_node: LeviathanNode = LEVIATHAN_NODE.instantiate()
		
		add_child(new_node)
		leviathan_nodes.append(new_node)
	
	while true:
		await get_tree().create_timer(0.1).timeout
		$Nav.target_position = target_position
		nav_target = $Nav.get_next_path_position()
		if !$Nav.is_target_reachable():
			_target_reached()

func _process(delta: float) -> void:
	super(delta)

func _physics_process(delta: float) -> void:
	update_leviathan_nodes(delta)
	
	velocity = Util.better_vec2_lerp(velocity, (nav_target - position).normalized() * target_speed, 0.2, delta)
	global_position += velocity * delta * 60
	
	if global_position.distance_to(target_position) < 20:
		_target_reached()

func update_leviathan_nodes(delta: float) -> void:
	rope.start_pos_on = true
	rope.start_pos = global_position
	
	for i in range(rope.point_amount - 1):
		leviathan_nodes[i].global_position = rope.points[i]
		if i == 0:
			leviathan_nodes[i].global_rotation = \
				Util.better_angle_lerp(
					leviathan_nodes[i].global_rotation, 
					rope.points[i].angle_to_point(target_position), 
					0.2, delta)
		else:
			leviathan_nodes[i].global_rotation = rope.points[i].angle_to_point(rope.points[i - 1])
