extends Node2D

func _ready():
	var static_bodies := Util.find_all_children_of_type(self, "StaticBody2D")
	
	var polygons: Array[CollisionPolygon2D]
	for body in static_bodies:
		for child in body.get_children():
			if child is CollisionPolygon2D:
				polygons.append(child)
	
	for polygon in polygons:
		var nav_polygon = Polygon2D.new()
		nav_polygon.polygon = polygon.polygon
		nav_polygon.position = polygon.global_position
		nav_polygon.visible = false
		$NavigationRegion2D.add_child(nav_polygon)
	
	$NavigationRegion2D.bake_navigation_polygon()
