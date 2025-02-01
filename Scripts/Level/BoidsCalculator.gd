# Owned by: carsonetb
class_name BoidsCalculator
extends Node


var boids_positions := []
var boids_velocities := []
var boids_rotations := []

@export var view_dist = 50
@export var protected_dist = 10
@export var num_boids = 1000
@export var bin_size = 32
@export var boid_gd_sync_batch_size = 50

# Local network sync is a lot more efficient.
@export var boid_local_network_sync_batch_size = 500

@onready var boids_scene := preload("res://Scenes/TSCN/Entities/NPCS/Boid.tscn")

var bins = Vector2.ZERO
var num_bins = 0
var rd: RenderingDevice
var boid_shader: RID
var boids_pipeline: RID
var shader_output: PackedFloat32Array
var boids_index_counter := 0
var boids_parameters_array: PackedFloat32Array
var boids_parameters_array_bytes: PackedByteArray
var boids_node_list := []
var threads_delta: float = 0

var mutex: Mutex
var semaphore: Semaphore
var thread: Thread
var exit_thread := false

# Load compute shader, and resize arrays.
func _ready() -> void:
	Global.boids_calculator_node = self
	
	print(RenderingServer.get_video_adapter_api_version())
	if RenderingServer.get_video_adapter_api_version().begins_with("3") || RenderingServer.get_video_adapter_api_version().begins_with("4"):
		print("ERROR: Compatibility (OpenGL) renderer does not support compute shaders. Boids will not run.")
		#boids wont exist so the silly boids dont need  to try to create skibidi
		self.process_mode = Node.PROCESS_MODE_DISABLED
		return
	
	rd = RenderingServer.create_local_rendering_device()
	
	var shader_file := load("res://Scripts/GLSL/Compute/compute_boids.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	boid_shader = rd.shader_create_from_spirv(shader_spirv)
	boids_pipeline = rd.compute_pipeline_create(boid_shader)
	
	boids_parameters_array.resize(2000 * 8)
	boids_node_list.resize(2000)
	
	# Setup up threading
	mutex = Mutex.new()
	semaphore = Semaphore.new()
	exit_thread = false
	
	await Global.save_load_framework.game_started
	
	thread = Thread.new()
	thread.start(_boids_compute)
	
	await get_tree().create_timer(5).timeout
	
	if Global.godot_steam_abstraction.is_lobby_owner:
		sync_at_integrals()

func _process(delta: float) -> void:
	var boids_list = get_tree().get_nodes_in_group("Boids")
	
	mutex.lock()
	threads_delta = delta
	boids_positions = []
	boids_velocities = []
	boids_rotations = []
	
	for boid_ind in range(boids_list.size()):
		var boid = boids_list[boid_ind]
		boids_positions.append(boid.position)
		boids_velocities.append(boid.velocity)
		boids_rotations.append(boid.rotation)
		
		boid.get_component("BoidComponent").index = boid_ind
	mutex.unlock()
	
	semaphore.post()

# Runs the GPU compute shader every frame! 
func _boids_compute() -> void:
	# Magic^TM delay fixes everything...
	# EDIT: I realized that we return if the number of boids is zero.
	OS.delay_msec(300)
	
	while true:
		# Wait for an update call from outside of the thread.
		semaphore.wait()
		
		# Lock the mutex. Whenever the variables that we access are used outside of the thread,
		# the mutex should be locked then too.
		mutex.lock()
		var threads_boids_positions = boids_positions
		var threads_boids_velocities = boids_velocities
		var threads_boids_rotations = boids_rotations
		var threads_boid_shader = boid_shader
		var threads_boids_pipeline = boids_pipeline
		var should_exit = exit_thread
		var delta = threads_delta
		var boids_list = get_tree().get_nodes_in_group("Boids")
		var num_boids_copy = boids_list.size()
		mutex.unlock()
		
		if num_boids_copy == 0:
			continue
		
		if should_exit: 
			break
		
		# Prepare data for compute shader
		var global_parameters := PackedFloat32Array([
			num_boids_copy,
			delta,
		])
		var global_parameters_bytes = global_parameters.to_byte_array()
		
		var positions := PackedVector2Array(threads_boids_positions)
		var positions_bytes = positions.to_byte_array()
		
		var velocities := PackedVector2Array(threads_boids_velocities)
		var velocities_bytes = velocities.to_byte_array()
		
		var rotations = PackedVector2Array(threads_boids_rotations)
		var rotations_bytes = rotations.to_byte_array()
		
		# TODO: This is probably unsafe, create a seperate array of raycasts to set later.
		# EDIT: I haven't seen any errors, that's not to say there aren't any.
		mutex.lock()
		var raycast_data := PackedFloat32Array()
		for boid in boids_list:
			var boid_component = boid.get_component("BoidComponent")
			raycast_data.append(1 if boid_component.raycast.get_collider() else 0)
			raycast_data.append(boid_component.raycast.get_collision_normal().x)
			raycast_data.append(boid_component.raycast.get_collision_normal().y)
		mutex.unlock()
		
		var raycast_data_bytes = raycast_data.to_byte_array()
		
		var output := PackedFloat32Array()
		output.resize(num_boids * 3)
		var output_bytes = output.to_byte_array()
		
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
		
		var rotations_buffer := rd.storage_buffer_create(rotations_bytes.size(), rotations_bytes)
		var rotations_uniform := RDUniform.new()
		rotations_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
		rotations_uniform.binding = 6
		rotations_uniform.add_id(rotations_buffer)
		
		# Create uniform set
		var uniform_set := rd.uniform_set_create(
			[
				parameters_uniform,
				global_parameters_uniform,
				positions_uniform,
				velocities_uniform,
				raycast_data_uniform,
				output_uniform,
				rotations_uniform
			],
			threads_boid_shader, 0
		)
		
		# Create compute pipeline
		var compute_list := rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, threads_boids_pipeline)
		rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
		rd.compute_list_dispatch(compute_list, num_boids_copy, 1, 1)
		rd.compute_list_end()
		
		# Execute compute shader ... this is not particularly efficient becuase we have to wait 
		# for the gpu to finish processing, but seeing as we're doing this every frame, I'm not sure 
		# what else we could do.
		# EDIT: Now that this is a seperate thread it's chill.
		rd.submit()
		rd.sync()
		
		# Get output list
		var compute_output_bytes := rd.buffer_get_data(output_buffer)
		
		mutex.lock()
		shader_output = compute_output_bytes.to_float32_array()
		mutex.unlock()

func get_shader_output():
	mutex.lock()
	var ret = shader_output
	mutex.unlock()
	return ret

func sync_at_integrals():
	while true:
		if Global.godot_steam_abstraction.is_lobby_owner:
			Global.godot_steam_abstraction.sync_var_in_group("Boids", "position")
			Global.godot_steam_abstraction.sync_var_in_group("Boids", "velocity")
		await get_tree().create_timer(0.01).timeout

# After this please use add_boid_data_at_index to fill in the registered data.
# Think of this like it's memory allocation in the boids list!
func register_index(boid_object: BoidComponent) -> int:
	if self.process_mode == Node.PROCESS_MODE_DISABLED:
		return 0
	boids_node_list[boids_index_counter] = boid_object
	boids_index_counter += 1
	return boids_index_counter - 1

func add_boid_data_at_index(index, view_distance, protected_distance, avoid_factor, matching_factor,
	centering_factor, turn_factor, max_speed, min_speed, max_accel):
	boids_parameters_array.set(index * 9 + 0, view_distance)
	boids_parameters_array.set(index * 9 + 1, protected_distance)
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
	
	boids_node_list.remove_at(id)
	
	# Range params are start, stop, and step.
	# Move all the indices backward because we just removed a node.
	for boid_index in range(id + 1, boids_node_list.size() - 1, 1):
		# Something's broken about this system but i don't want to fix it.
		if boids_node_list[boid_index]:
			boids_node_list[boid_index].boids_index -= 1
	
	boids_parameters_array_bytes = boids_parameters_array.to_byte_array()

func _run_compute_shader(pipeline, uniform_set):
	# Create compute pipeline
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
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
