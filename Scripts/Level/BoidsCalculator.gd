class_name BoidsCalculator
extends Node


var boids_positions := []
var boids_velocities := []

@export var view_dist = 50
@export var protected_dist = 10
@export var num_boids = 1000
@export var bin_size = 32

var bins = Vector2.ZERO
var num_bins = 0
var rd: RenderingDevice
var boid_shader: RID
var boids_pipeline: RID
var shader_output = []
var boids_index_counter := 0
var boids_parameters_array: PackedFloat32Array
var boids_parameters_array_bytes: PackedByteArray
var boids_node_list := []

# Load compute shader, and resize arrays.
func _ready() -> void:
	rd = RenderingServer.create_local_rendering_device()
	
	var shader_file := load("res://Scripts/GLSL/compute_boids.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	boid_shader = rd.shader_create_from_spirv(shader_spirv)
	boids_pipeline = rd.compute_pipeline_create(boid_shader)
	
	boids_parameters_array.resize(2000 * 8)
	boids_node_list.resize(2000)
	
	Global.boids_calculator_node = self

# Runs the GPU compute shader every frame! 
func _physics_process(delta: float) -> void:
	var boids_list = get_tree().get_nodes_in_group("Boids")
	var num_boids = boids_list.size()
	
	boids_positions = []
	boids_velocities = []
	
	for boid_ind in range(boids_list.size()):
		boids_positions.append(boids_list[boid_ind].position)
		boids_velocities.append(boids_list[boid_ind].velocity)
		
		# TODO: Make this safe.
		boids_list[boid_ind].get_node("BoidComponent").index = boid_ind
	
	# Prepare data for compute shader
	var global_parameters := PackedFloat32Array([
		num_boids,
		delta,
	])
	var global_parameters_bytes = global_parameters.to_byte_array()
	
	var positions := PackedVector2Array(boids_positions)
	var positions_bytes = positions.to_byte_array()
	
	var velocities := PackedVector2Array(boids_velocities)
	var velocities_bytes = velocities.to_byte_array()
	
	var raycast_data := PackedFloat32Array()
	for boid in boids_list:
		var boid_component = boid.get_node("BoidComponent")
		raycast_data.append(1 if boid_component.raycast.get_collider() else 0)
		raycast_data.append(boid_component.raycast.get_collision_normal().x)
		raycast_data.append(boid_component.raycast.get_collision_normal().y)
	var raycast_data_bytes = raycast_data.to_byte_array()
	
	var output := PackedFloat32Array()
	for i in range(num_boids):
		output.append_array([0, 0, 0, 0, 0, 0, 0])
	var output_bytes = output.to_byte_array()
	
	var bin_params_buffer_bytes = PackedFloat32Array([bin_size, bins.x, bins.y, num_bins]).to_byte_array()
	
	# Create data uniforms
	var parameters_buffer := rd.storage_buffer_create(boids_parameters_array_bytes.size(), boids_parameters_array_bytes)
	var parameters_uniform := RDUniform.new()
	parameters_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	parameters_uniform.binding = 0
	parameters_uniform.add_id(parameters_buffer)
	
	var global_parameters_buffer := rd.storage_buffer_create(global_parameters_bytes.size(), global_parameters_bytes)
	var global_parameters_uniform := RDUniform.new()
	global_parameters_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	global_parameters_uniform.binding = 1
	global_parameters_uniform.add_id(global_parameters_buffer)
	
	var positions_buffer := rd.storage_buffer_create(positions_bytes.size(), positions_bytes)
	var positions_uniform := RDUniform.new()
	positions_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	positions_uniform.binding = 2
	positions_uniform.add_id(positions_buffer)
	
	var velocities_buffer := rd.storage_buffer_create(velocities_bytes.size(), velocities_bytes)
	var velocities_uniform := RDUniform.new()
	velocities_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	velocities_uniform.binding = 3
	velocities_uniform.add_id(velocities_buffer)
	
	var raycast_data_buffer := rd.storage_buffer_create(raycast_data_bytes.size(), raycast_data_bytes)
	var raycast_data_uniform := RDUniform.new()
	raycast_data_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	raycast_data_uniform.binding = 4
	raycast_data_uniform.add_id(raycast_data_buffer)
	
	var output_buffer := rd.storage_buffer_create(output_bytes.size(), output_bytes)
	var output_uniform := RDUniform.new()
	output_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	output_uniform.binding = 5
	output_uniform.add_id(output_buffer)
	
	# Create uniform set
	var uniform_set := rd.uniform_set_create(
		[
			parameters_uniform, 
			global_parameters_uniform,
			positions_uniform, 
			velocities_uniform, 
			raycast_data_uniform, 
			output_uniform,
		], 
		boid_shader, 0
	)
	
	_run_compute_shader(boids_pipeline, uniform_set)
	
	# Get output list
	var compute_output_bytes := rd.buffer_get_data(output_buffer)
	shader_output = compute_output_bytes.to_float32_array()
	
	pass

# After this please use add_boid_data_at_index to fill in the registered data.
# Think of this like it's memory allocation in the boids list!
func register_index(boid_object: BoidComponent) -> int:
	boids_node_list[boids_index_counter] = boid_object
	boids_index_counter += 1
	return boids_index_counter - 1

func add_boid_data_at_index(index, view_dist, protected_dist, avoid_factor, matching_factor, 
							centering_factor, turn_factor, max_speed, min_speed, max_accel):
	boids_parameters_array.set(index * 9 + 0, view_dist)
	boids_parameters_array.set(index * 9 + 1, protected_dist)
	boids_parameters_array.set(index * 9 + 2, avoid_factor)
	boids_parameters_array.set(index * 9 + 3, matching_factor)
	boids_parameters_array.set(index * 9 + 4, centering_factor)
	boids_parameters_array.set(index * 9 + 5, turn_factor)
	boids_parameters_array.set(index * 9 + 6, max_speed)
	boids_parameters_array.set(index * 9 + 7, min_speed)
	boids_parameters_array.set(index * 9 + 8, max_accel)
	boids_parameters_array_bytes = boids_parameters_array.to_byte_array()

# Do this always before you free a boid ... it's not *particularly* neccesary
# and won't cause any bugs if you don't do it. Think of this like a memory free!
func remove_boid_index(id):
	for i in range(9):
		boids_parameters_array.remove_at(id)
	
	# Range params are start, stop, and step.
	# Move all the indices backward because we just removed a node.
	for boid_index in range(id, boids_parameters_array.size(), 1):
		boids_node_list[boid_index].boids_index -= 1
	
	boids_parameters_array_bytes = boids_parameters_array.to_byte_array()

func _run_compute_shader(pipeline, uniform_set):
	# Create compute pipeline
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, boids_pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, num_boids, 1, 1)
	rd.compute_list_end()
	
	# Execute compute shader ... this is not particularly efficient becuase we have to wait 
	# for the gpu to finish processing, but seeing as we're doing this every frame, I'm not sure 
	# what else we could do.
	rd.submit()
	rd.sync()

func _generate_storage_uniform(buffer, binding) -> RDUniform:
	var output_uniform = RDUniform.new()
	output_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	output_uniform.binding = binding
	output_uniform.add_id(buffer)
	return output_uniform

func _generate_float_buffer(size) -> RID:
	var data = []
	data.resize(size)
	var data_buffer_bytes = PackedFloat32Array(data).to_byte_array()
	var data_buffer = rd.storage_buffer_create(data_buffer_bytes.size(), data_buffer_bytes)
	return data_buffer
