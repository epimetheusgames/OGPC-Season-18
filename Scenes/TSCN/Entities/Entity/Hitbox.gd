extends CollisionShape2D
func _ready():
	self.shape = RectangleShape2D.new()
	self.shape.size = get_parent().get_node("Texture").texture.get_size()
	#hitbox for interacting with npc, you shouldnt need to be touching them to talk with them
	var dialog_hitbox = CollisionShape2D.new()
	dialog_hitbox.shape = RectangleShape2D.new()
	dialog_hitbox.shape.size = get_parent().get_node("Hitbox").shape.size + Vector2(get_parent().dialog_hitbox_size,get_parent().dialog_hitbox_size)
	self.get_parent().get_node("DialogHitbox").add_child(dialog_hitbox)
	print("edging")
