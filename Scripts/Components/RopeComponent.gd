class_name Rope

extends Node2D

@export var length = 100
@export var line_color: Color = Color.CORAL

@export var start_width: float = 10
@export var end_width: float = 10

@export var start_anchor_node: Node2D
@export var end_anchor_node: Node2D

const DIST_BETWEEN_POINTS: float = 5

var start_pos: Vector2 = Vector2()
var end_pos: Vector2 = Vector2()

func _ready():
	var line = Line2D.new()
	line.name = "line"
	line.top_level = true
	line.width = 0
	
	# Create points between start and end positions
	for i in range(length):
		var t = float(i) / float(length - 1)
		line.add_point(start_pos.lerp(end_pos, t))
	
	add_child(line)

func _process(delta):
	var line: Line2D = get_node("line") as Line2D
	
	# Update start and end positions
	if start_anchor_node:
		start_pos = start_anchor_node.global_position
	if end_anchor_node:
		end_pos = end_anchor_node.global_position
	
	pull_toward_anchor2()
	pull_toward_anchor1()
	
	queue_redraw()

func pull_toward_anchor1():
	if start_anchor_node:
		var line: Line2D = get_node("line") as Line2D
		line.set_point_position(0, start_pos)
		
		for i in range(length - 1):
			var point_1 = line.get_point_position(i + 1)
			var point_2 = line.get_point_position(i)
			line.set_point_position(
				i + 1, constrain_distance(point_1, point_2, DIST_BETWEEN_POINTS)
			)

func pull_toward_anchor2():
	if end_anchor_node:
		var line: Line2D = get_node("line") as Line2D
		
		line.set_point_position(length - 1, end_pos)
		
		for i in range(length - 1):
			var point_1 = line.get_point_position(length - i - 2)
			var point_2 = line.get_point_position(length - i - 1)
			line.set_point_position(
				length - i - 2, constrain_distance(point_1, point_2, DIST_BETWEEN_POINTS)
			)


# Project point onto circle around anchor
func constrain_distance(point: Vector2, anchor: Vector2, distance: float) -> Vector2:
	var direction: Vector2 = point - anchor
	return anchor + direction.normalized() * distance

# Draw the points in Line2D relative to this node's global position
func _draw():
	var line: Line2D = $"line" as Line2D
	
	for i in range(line.get_point_count()):
		var pos: Vector2 = line.get_point_position(i) - global_position
		var t: float = float(i) / float(line.get_point_count() - 1)
		var radius: float = lerp(start_width, end_width, t)
		draw_circle(pos, radius, line_color)
