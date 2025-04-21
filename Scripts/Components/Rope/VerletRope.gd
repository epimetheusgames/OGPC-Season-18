class_name VerletRope
extends BaseRope

const TIMESTEP: float = 0.1

@onready var rng := RandomNumberGenerator.new()

@export var iterations: int = 2
@export var gravity: Vector2 = Vector2(0, 100)
@export var damping: float = 0.98  # 1 = no damping, < 1 slows movement

var verlet_nodes: Array[VerletNode]
var is_on_screen := true
var rope_drawer: RopeLineDrawer
var normals: Array[Vector2]

func _ready() -> void:
	super()
	component_name = "VerletRope"
	
	var spawn_pos: Vector2 = get_node(component_container).global_position if component_container else Vector2.ZERO
	
	verlet_nodes.resize(point_amount)
	for i in range(point_amount):
		verlet_nodes[i] = VerletNode.new()
		verlet_nodes[i].set_up(spawn_pos) 
	
	normals.resize(point_amount)

func _process(delta: float) -> void:
	super(delta)
	
	if !is_on_screen:
		return
	
	if start_anchor_node:
		start_pos = start_anchor_node.global_position
	if end_anchor_node:
		end_pos = end_anchor_node.global_position
	
	simulate(delta)
	
	for i in range(iterations):
		apply_constraints()
	
	for i in range(verlet_nodes.size()):
		points[i] = verlet_nodes[i].position
		
	if rope_drawer:
		rope_drawer.points = points

func simulate(delta: float):
	for i in range(point_amount):
		var node: VerletNode = verlet_nodes[i]
		var temp: Vector2 = node.position
		
		var velocity: Vector2 = (node.position - node.old_position) * damping
		velocity += gravity * (TIMESTEP * TIMESTEP)
		
		node.position += velocity
		node.old_position = temp

func apply_constraints():
	if start_pos_on:
		verlet_nodes[0].position = start_pos
	if end_pos_on:
		verlet_nodes[point_amount - 1].position = end_pos
	
	for i in range(point_amount - 1):
		var node_1: VerletNode = verlet_nodes[i]
		var node_2: VerletNode = verlet_nodes[i + 1]
		
		var direction: Vector2 = node_2.position - node_1.position
		var distance: float = direction.length()
		
		if distance == 0:
			continue
		
		direction = direction.normalized()
		var difference_factor: float = point_separation - distance
		var translate: Vector2 = direction * difference_factor * 0.5
		
		node_1.position -= translate
		node_2.position += translate

class VerletNode:
	var position: Vector2
	var old_position: Vector2
	
	func set_up(position: Vector2):
		self.position = position
		self.old_position = position
