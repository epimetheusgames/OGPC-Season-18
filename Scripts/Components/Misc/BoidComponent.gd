# Owned by: carsonetb
class_name BoidComponent
extends BaseComponent


@export var view_dist: float = 50
@export var protected_dist: float = 10
@export var avoid_factor: float = 0.01
@export var matching_factor: float = 0.1
@export var centering_factor: float = 0.0005
@export var turn_factor: float = 0.5
@export var max_speed: float = 50
@export var min_speed: float = 1.5
@export var max_accel: float = 100

var boid_initialized := false
var boids_calculator: BoidsCalculator
var boids_index: int
var index: int
var raycast: RayCast2D

@export_node_path("RayCast2D") var raycast_path
@export var follow_position: Node2D
@onready var component_container_node = get_node(component_container)
@export var boid_colors: Array[Color]

func _ready():
	_ready_boid()

func _ready_boid() -> void:
	component_name = "BoidComponent"
	name = "BoidComponent"
	
	_ready_base_component()
	
	if !component_container:
		return
	
	if !"get_entity_type" in get_node(component_container):
		print("WARNING: BoidComponent at " + str(get_path()) + " requires its container to be an Entity. The component will not be functional.")
		return
	
	boids_calculator = Global.boids_calculator_node
	
	if boids_calculator.process_mode == Node.PROCESS_MODE_DISABLED:
		component_container_node.queue_free()
		return
	
	boids_index = boids_calculator.register_index(self)
	boids_calculator.add_boid_data_at_index(boids_index, view_dist, protected_dist, avoid_factor,
											matching_factor, centering_factor, turn_factor,
											max_speed, min_speed, max_accel)
	
	get_parent().add_to_group("Boids")
	raycast = get_node(raycast_path)
	get_parent().velocity = (raycast.target_position - raycast.position).normalized()
	
	var rng := RandomNumberGenerator.new()
	component_container_node.modulate = boid_colors[rng.randi_range(0, len(boid_colors) - 1)]

# Update velocity using compute shader outputs from boids calculator node.
func _process(delta: float) -> void: 
	if boids_calculator.process_mode == Node.PROCESS_MODE_DISABLED:
		return
	
	if component_container && boids_calculator.shader_output.size() - 1 > boids_index:
		var output = boids_calculator.get_shader_output()
		component_container_node.velocity = Vector2(output[boids_index * 3], output[boids_index * 3 + 1])
		component_container_node.position += component_container_node.velocity
		
	get_parent().rotation = Util.better_angle_lerp(get_parent().rotation, atan2(get_parent().velocity.normalized().y, get_parent().velocity.normalized().x) + PI / 2.0 + PI, 0.1, delta)
