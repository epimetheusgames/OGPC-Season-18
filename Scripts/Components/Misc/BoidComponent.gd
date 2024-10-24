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

func _ready():
	name = "BoidComponent"
	component_name = "BoidComponent"
	
	if !component_container:
		return
	
	if !"get_entity_type" in get_node(component_container):
		print("WARNING: BoidComponent at " + str(get_path()) + " requires its container to be an Entity. The component will not be functional.")
		return
	
	boids_calculator = Global.boids_calculator_node
	boids_index = boids_calculator.register_index(self)
	boids_calculator.add_boid_data_at_index(boids_index, view_dist, protected_dist, avoid_factor,
											matching_factor, centering_factor, turn_factor,
											max_speed, min_speed, max_accel)
	
	get_parent().add_to_group("Boids")
	raycast = get_node(raycast_path)
	get_parent().velocity = (raycast.target_position - raycast.position).normalized()
	
	_base_component_ready_post()

# Update velocity using compute shader outputs from boids calculator node.
func _process(delta: float) -> void: 
	if component_container && boids_calculator.shader_output.size() - 1 > boids_index:
		get_node(component_container).velocity = Vector2(boids_calculator.shader_output[boids_index * 2], boids_calculator.shader_output[boids_index * 2 + 1])
		get_node(component_container).move_and_slide()
		get_node(component_container).position += get_node(component_container).velocity
		
	get_parent().rotation = atan2(get_parent().velocity.normalized().y, get_parent().velocity.normalized().x) + PI / 2.0 + PI
