extends Node2D


@onready var polygons: Array[CollisionPolygon2D] = [$NavigationMeshObject1/CollisionPolygon2D, $NavigationMeshObject2/CollisionPolygon2D]

func _ready():
	for polygon in polygons:
		var nav_polygon = Polygon2D.new()
		nav_polygon.polygon = polygon.polygon
		nav_polygon.position = polygon.global_position
		nav_polygon.visible = false
		$NavigationRegion2D.add_child(nav_polygon)
	
	$NavigationRegion2D.bake_navigation_polygon()
