extends CollisionShape2D
func _ready():
	get_parent().get_node("Hitbox").shape = RectangleShape2D.new()
	get_parent().get_node("Hitbox").shape.size = get_parent().get_node("Texture").texture.get_size()
