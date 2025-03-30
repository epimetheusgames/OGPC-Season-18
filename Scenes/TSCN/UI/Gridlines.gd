extends Node2D

@export var grid_columns : int = 4
@export var grid_rows : int = 4
@export var grid_size : float = 400

func _physics_process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	for i in grid_rows + 1:
		draw_line(Vector2(0, grid_size * i), Vector2(grid_columns * grid_size, grid_size * i), Color(255,255,255), 2, true)
	for i in grid_columns + 1:
		draw_line(Vector2(grid_size * i, 0), Vector2(grid_size * i, grid_rows * grid_size), Color(255,255,255), 2, true)
