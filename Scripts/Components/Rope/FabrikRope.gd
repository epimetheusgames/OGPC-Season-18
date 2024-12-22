## Fabrik (Forwards and backwards reaching inverse kinematics)
## is a way of doing IK that works by constraining points to a certain distance from each other
# Owned by: kaitaobenson

class_name FabrikRope
extends BaseRope

func _ready() -> void:
	_ready_rope()
	component_name = "FabrikRope"

func _process(delta):
	pull_toward_anchor2()
	pull_toward_anchor1()

func pull_toward_anchor1():
	if start_anchor_node:
		points[0] = start_pos
		
		for i in range(point_amount - 1):
			var point_1 = points[i + 1]
			var point_2 = points[i]
			points[i + 1] = constrain_distance(point_1, point_2, point_separation)

func pull_toward_anchor2():
	if end_anchor_node:
		points[point_amount - 1] = end_pos
		
		for i in range(point_amount - 1):
			var point_1 = points[point_amount - i - 2]
			var point_2 = points[point_amount - i - 1]
			points[point_amount - i - 2] = constrain_distance(point_1, point_2, point_separation)

# Project point onto circle around anchor
func constrain_distance(point: Vector2, anchor: Vector2, distance: float) -> Vector2:
	var direction: Vector2 = point - anchor
	return anchor + direction.normalized() * distance
