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

@export var grid_columns : int = 4
@export var grid_rows : int = 4
@export var grid_size : int = 400

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

func _on_control_module_button_up() -> void:
	if !adding_module:
		add_module(control_module.instantiate())

func _on_corner_passage_module_button_up() -> void:
	if !adding_module:
		add_module(submarine_corner_passage_module.instantiate())

func _on_passage_module_button_up() -> void:
	if !adding_module:
		add_module(submarine_passage_module.instantiate())

func _on_end_passage_module_button_up() -> void:
	if !adding_module:
		add_module(submarine_end_module.instantiate())

func _on_door_module_button_up() -> void:
	if !adding_module:
		add_module(submarine_door_module.instantiate())

func _on_weapons_module_button_up() -> void:
	if !adding_module:
		add_module(submarine_weapons_module.instantiate())

func _process(delta: float) -> void:
	if adding_module:
		var valid_point: AttachmentPoint = null
		var our_valid_point: AttachmentPoint = null
		#
		
		module_adding.global_position = find_closest_grid_spot(module_adding.get_global_mouse_position())
		var cell_position = (module_adding.global_position - Vector2(.5 * grid_size, .5 * grid_size)) / grid_size
		
		#print(module_grid)
		
		if Input.is_action_just_pressed("mouse_left_click"):
			var attachment_point_connections : Dictionary = {
			}
			
			var grid_space_is_valid : bool = true
			# Checks for if grid space is valid
			# TODO this should be where points to be attached should be marked, or at least code copied from here
			if !is_cell_valid(cell_position):
				grid_space_is_valid = false
				print("Cell isn't valid")
			elif module_grid[cell_position.y][cell_position.x] != null:
				grid_space_is_valid = false
				print("Grid space is in use")
			else:
				var directions : Array[Vector2] = [
					Vector2(1,0),
					Vector2(0,1),
					Vector2(-1,0),
					Vector2(0,-1),
				]
				
				var module_will_attach : bool = false
				print("new mod")
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
								print("Attachment point doesn't have a attachment point in the adjacent module to attach to")
								break
						
					else:
						grid_space_is_valid = false
						print("Attachment point points out of bounds")
						break
				
				print(module_will_attach)
				if !module_will_attach && modules.size() != 1:
					grid_space_is_valid = false
					print("Module can't attach to anything in the position")
				
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
										print("Adjacent cell has attachment point that wouldn't be attached")
										break
						else:
							continue
			
			if grid_space_is_valid:
				if modules.size() == 1:
					module_grid[cell_position.y][cell_position.x] = module_adding
					module_adding = null
					adding_module = false
					for i in module_grid:
						print(i)
				else:
					module_grid[cell_position.y][cell_position.x] = module_adding
					#module_adding.position += (valid_point.global_position - our_valid_point.global_position)
					for point in attachment_point_connections.keys(): 
						point.attached_point = attachment_point_connections[point]
						attachment_point_connections[point].attached_point = point
					
					module_adding = null
					adding_module = false
			
		if Input.is_action_just_pressed("rotate_peice"):
			module_adding.rotate_module(PI / 2)
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

func find_assosiated_point(point: Vector2, direction: Vector2, multiplier: int = 1) -> AttachmentPoint:
	for module in modules:
		for real_point in module.attachment_points:
			if real_point.global_position.distance_to(point) < 1 && real_point.direction.is_equal_approx(direction * multiplier):
				return real_point
	return null

# TODO: Add more stuff here.
func do_submarine_sanity_checks() -> bool:
	for module in modules:
		for point in module.attachment_points:
			if !point.attached_point:
				return false
	return true

func _on_save_button_button_up() -> void:
	if !do_submarine_sanity_checks():
		print("WARNING: Invalid submarine.")
		return 
		
	$SaveDialog.visible = true

func _on_load_button_button_up() -> void:
	$LoadDialog.visible = true

func _on_save_dialog_file_selected(path: String) -> void:
	var sub_resource = CustomSubmarineResource.new()
	for module in modules:
		sub_resource.modules.append(module.create_module_resource())
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("")
	file.close()
	ResourceSaver.save(sub_resource, path)

func _on_load_dialog_file_selected(path: String) -> void:
	var sub_resource: CustomSubmarineResource = ResourceLoader.load(path)
	
	# Pass 1, load module positions.
	for module in sub_resource.modules:
		var new_module: SubmarineModule = load(module.module_scene.file).instantiate()
		new_module.position = module.position
		new_module.render_attachment_points = true
		origin.add_child(new_module)
		modules.append(new_module)
	
	# Pass two, load connections.
	for module in sub_resource.modules:
		for attachment_resource in module.attachment_points:
			if attachment_resource.is_attached:
				var real_point := find_assosiated_point(attachment_resource.position + module.position + origin.global_position, attachment_resource.direction)
				real_point.attached_point = find_assosiated_point(attachment_resource.position + module.position + origin.global_position, attachment_resource.direction, -1)

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
