# Owned by carsonetb and Xavier J
class_name SubmarineEditor
extends Control

@onready var origin = $"SplitContainer/SubmarineView/ViewContainer/Viewport/Origin"
@onready var grid = $"SplitContainer/PanelContainer/VSplitContainer/GridContainer"

@onready var control_module := preload("res://Scenes/TSCN/Entities/Submarine/SubmarineModules/SubmarineControlModule.tscn")
@onready var submarine_corner_passage_module := preload("res://Scenes/TSCN/Entities/Submarine/SubmarineModules/SubmarineCornerPassageModule.tscn")
@onready var submarine_passage_module := preload("res://Scenes/TSCN/Entities/Submarine/SubmarineModules/SubmarinePassageModule.tscn")
@onready var submarine_end_module := preload("res://Scenes/TSCN/Entities/Submarine/SubmarineModules/SubmarineEndModule.tscn")
@onready var submarine_door_module := preload("res://Scenes/TSCN/Entities/Submarine/SubmarineModules/SubmarineDoorModule.tscn")
@onready var submarine_weapons_module := preload("res://Scenes/TSCN/Entities/Submarine/SubmarineModules/SubmarineWeaponsModule.tscn")
@onready var submarine_T_module := preload("res://Scenes/TSCN/Entities/Submarine/SubmarineModules/SubmarineTModule.tscn")

@export var grid_columns : int = 4
@export var grid_rows : int = 4
@export var grid_size : int = 400

var has_control_module := false
var control_module_position : Vector2

var modules: Array[SubmarineModule] = []
var adding_module := false
var module_adding: SubmarineModule

var module_grid : Array[Array] = []

func _ready() -> void:
	for i in grid_rows:
		module_grid.append([])
		for j in grid_columns:
			module_grid[i].append(null)
	print(module_grid)

func add_module(new_module: SubmarineModule):
	adding_module = true
	new_module.render_attachment_points = true
	new_module.is_editor_peice = true
	origin.add_child(new_module)
	module_adding = new_module
	modules.append(new_module)

func module_adding_checks(require_control_module := true) -> bool:
	if !has_control_module && require_control_module:
		return false
	
	if has_control_module && !require_control_module:
		return false

	if adding_module:
		module_adding.queue_free()
		module_adding = null
		adding_module = false
	
	return true

func _on_control_module_button_up() -> void:
	if module_adding_checks(false):
		add_module(control_module.instantiate())

func _on_corner_passage_module_button_up() -> void:
	if module_adding_checks():
		add_module(submarine_corner_passage_module.instantiate())

func _on_passage_module_button_up() -> void:
	if module_adding_checks():
		add_module(submarine_passage_module.instantiate())

func _on_end_passage_module_button_up() -> void:
	if module_adding_checks():
		add_module(submarine_end_module.instantiate())

func _on_door_module_button_up() -> void:
	if module_adding_checks():
		add_module(submarine_door_module.instantiate())

func _on_weapons_module_button_up() -> void:
	if module_adding_checks():
		add_module(submarine_weapons_module.instantiate())

func _on_t_module_button_up() -> void:
	if module_adding_checks():
		add_module(submarine_T_module.instantiate())

func _process(delta: float) -> void:
	if adding_module:
		var valid_point: AttachmentPoint = null
		var our_valid_point: AttachmentPoint = null
		
		module_adding.global_position = find_closest_grid_spot(module_adding.get_global_mouse_position())
		var cell_position = (module_adding.global_position - Vector2(.5 * grid_size, .5 * grid_size)) / grid_size
		
		if Input.is_action_just_pressed("mouse_left_click"):
			var attachment_point_connections : Dictionary = {}
			
			var grid_space_is_valid : bool = true
			# Checks for if grid space is valid
			# TODO this should be where points to be attached should be marked, or at least code copied from here
			if !is_cell_valid(cell_position):
				grid_space_is_valid = false
				Global.print_error("Cell isn't valid.")
			elif module_grid[cell_position.y][cell_position.x] != null:
				grid_space_is_valid = false
				Global.print_error("Grid space is occupied.")
			else:
				var directions : Array[Vector2] = [
					Vector2(1,0),
					Vector2(0,1),
					Vector2(-1,0),
					Vector2(0,-1),
				]
				
				var module_will_attach : bool = false
				for point in module_adding.attachment_points:
					var adjacent_cell_pos : Vector2i = (cell_position + point.direction).round()
					if is_cell_valid(adjacent_cell_pos):
						print("Cell is valid")
						
						if module_grid[adjacent_cell_pos.y][adjacent_cell_pos.x] != null:
							print("Cell is open")
							var available_point : bool = false
							
							for adjacent_module_point in module_grid[adjacent_cell_pos.y][adjacent_cell_pos.x].attachment_points:
								if point.direction.is_equal_approx(-adjacent_module_point.direction):
									available_point = true
									module_will_attach = true
									attachment_point_connections[point] = adjacent_module_point
									# This is just to remove the extra direction check of already checked directions for efficiency
									directions.remove_at(directions.find(point.direction.round()))
									print(directions)
									print("skiub")
									break
							
							if !available_point:
								grid_space_is_valid = false
								Global.print_error("Attachment point doesn't have an attachment point in its adjacent module to attach to")
								break
						
					else:
						grid_space_is_valid = false
						Global.print_error("Attachment point out of bounds")
						break
				
				if !module_will_attach && modules.size() != 1:
					grid_space_is_valid = false
					Global.print_error("Module can't attach to anything in its position")
				
				# Iterates through all the directions that do not have an attachment point
				if modules.size() != 1:
					for direction in directions:
						if !grid_space_is_valid:
							break
						
						var adjacent_cell_pos : Vector2i = (cell_position + direction).round()
						if is_cell_valid(adjacent_cell_pos):
							var adjacent_cell : SubmarineModule = module_grid[cell_position.y][cell_position.x]
							if adjacent_cell != null:
								for point in adjacent_cell.attachment_points:
									if point.direction.is_equal_approx(-direction):
										grid_space_is_valid = false
										Global.print_error("Adjacent cell has attachment point that wouldn't be attached")
										break
						else:
							continue
			
			if grid_space_is_valid:
				if module_adding is SubmarineControlModule:
					has_control_module = true
					control_module_position = module_adding.position
				if modules.size() == 1:
					module_grid[cell_position.y][cell_position.x] = module_adding
					module_adding.grid_position = Vector2i(cell_position.x, cell_position.y)
					module_adding = null
					adding_module = false
					for i in module_grid:
						print(i)
				else:
					module_grid[cell_position.y][cell_position.x] = module_adding
					module_adding.grid_position = Vector2i(cell_position.x, cell_position.y)
					for point in attachment_point_connections.keys():
						point.is_attached = true
						attachment_point_connections[point].is_attached = true
					
					module_adding = null
					adding_module = false
			
		if Input.is_action_just_pressed("rotate_peice"):
			module_adding.rotate_module()

		if Input.is_action_just_pressed("mouse_right_click"):
			if module_adding is SubmarineControlModule:
				has_control_module = false

			module_adding.queue_free()
			module_adding = null
			adding_module = false

	if Input.is_action_just_pressed("mwUP"):
		$SplitContainer/SubmarineView/ViewContainer/Viewport/Camera2D.zoom *= 1.1
	if Input.is_action_just_pressed("mwDOWN"):
		$SplitContainer/SubmarineView/ViewContainer/Viewport/Camera2D.zoom *= 0.9
	
	queue_redraw()

#func _draw() -> void:
	#if adding_module:
		#for module in modules:
			#if module == module_adding:
				#continue
			#for point in module.attachment_points:
				#for our_point in module_adding.attachment_points:
					#if point.direction.is_equal_approx(-our_point.direction) && point.global_position.distance_to(our_point.global_position) < 100 && !point.attached_point && !our_point.attached_point:
						#draw_line(our_point.global_position - global_position, point.global_position - global_position, Color.RED, 2)

# TODO: Add more stuff here.
func do_submarine_sanity_checks() -> bool:
	var has_control_module = false
	for module in modules:
		if module is SubmarineControlModule:
			if has_control_module:
				return false
			else:
				has_control_module = true
		for point in module.attachment_points:
			if !point.is_attached:
				return false
	
	if has_control_module:
		return true
	return false

func _on_save_button_button_up() -> void:
	if !do_submarine_sanity_checks():
		Global.print_error("Invalid submarine.")
		return
		
	$SaveDialog.visible = true

func _on_load_button_button_up() -> void:
	$LoadDialog.visible = true

func _on_save_dialog_file_selected(path: String) -> void:
	var sub_resource = CustomSubmarineResource.new()
	var has_control_module := false
	sub_resource.control_module_position = control_module_position
	for module in modules:
		sub_resource.modules.append(module.create_module_resource())
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("")
	file.close()
	ResourceSaver.save(sub_resource, path)

func _on_load_dialog_file_selected(path: String) -> void:
	var sub_resource: CustomSubmarineResource = ResourceLoader.load(path)
	
	has_control_module = true
	control_module_position = sub_resource.control_module_position
	
	# Some time in the future make it load the grid size parameters and shi
	for i in grid_rows:
		module_grid.append([])
		for j in grid_columns:
			module_grid[i].append(null)
	
	modules = []
	
	for module in sub_resource.modules:
		var new_module: SubmarineModule = load(module.module_scene.file).instantiate()
		new_module.position = module.position
		new_module.grid_position = module.grid_position
		new_module.render_attachment_points = true
		new_module.is_editor_peice = true
		
		origin.add_child(new_module)
		for i in range(len(module.attachment_points)):
			new_module.attachment_points[i].is_attached = true
		if round(fmod(module.rotation, 2*PI)) != 0:
			for i in range(round(module.rotation / deg_to_rad(new_module.rotation_increment))):
				print(module.rotation)
				new_module.rotate_module()
		
		modules.append(new_module)
		module_grid[module.grid_position.y][module.grid_position.x] = new_module

func find_closest_grid_spot(pos : Vector2) -> Vector2:
	var distance_to_gridline = Vector2(fmod(pos.x, grid_size), fmod(pos.y, grid_size))
	if pos.x >= 0:
		pos.x -= distance_to_gridline.x - .5 * grid_size
	else:
		pos.x -= distance_to_gridline.x + .5 * grid_size
	if pos.y >= 0:
		pos.y -= distance_to_gridline.y - .5 * grid_size
	else:
		pos.y -= distance_to_gridline.y + .5 * grid_size
	
	return pos

func is_cell_valid(cell_position):
	if grid_columns <= cell_position.x || cell_position.x <= -1 || grid_rows <= cell_position.y || cell_position.y <= -1:
		return false
	else:
		return true
