# Coded by Xavier
class_name Submarine
extends Entity

# Tutorial stuff
signal entered_submarine
signal driving_submarine

@onready var submarine_movement = $"SubmarineMovement"
@onready var seat_pos = $"InteractionArea/SeatPos"
@onready var aura = $"SubmarineAura"
@onready var interior_texture = $"Interior"
@onready var exterior_texture = $"Exterior"
@onready var hurtbox = $"Hurtbox"

var navigation_obstacle : StaticBody2D
var collision_shapes : Array[CollisionPolygon2D]

var players_inside : int = 0

var flipped : bool = false

signal sub_flipped()

func _ready() -> void:
	hurtbox.damaged.connect(damaged)
	hurtbox.died.connect(die)
	if !Global.submarine:
		Global.submarine = self
	navigation_obstacle = StaticBody2D.new()
	navigation_obstacle.name = "NavigationObstacle"
	navigation_obstacle.collision_layer = 1
	navigation_obstacle.collision_mask = 0
	navigation_obstacle.add_to_group("obstacles")
	add_child(navigation_obstacle, true)
	
	if get_node_or_null("Collision"):
		for child in get_node_or_null("Collision").get_children():
			var old_pos: Vector2 = child.global_position
			var old_rot: float = child.global_rotation
			$NavigationObstacle.add_child(child.duplicate())
			$"Collision".remove_child(child)
			add_child(child)
			collision_shapes.append(child)
			child.global_position = old_pos
			child.global_rotation = old_rot
	
	if get_node_or_null("Pivot"):
		get_node("Pivot").set_node_variables()

func _process(delta: float) -> void:
	if Global.is_multiplayer && _is_node_owner():
		Global.godot_steam_abstraction.sync_var(self, "velocity")
		Global.godot_steam_abstraction.sync_var(self, "position")
		Global.godot_steam_abstraction.sync_var(self, "rotation")
	
	aura.global_rotation = 0.0
	if Global.player.get_state() == Diver.DiverState.DRIVING_SUBMARINE:
		Global.player.global_transform = seat_pos.global_transform

func _physics_process(_delta: float) -> void:
	velocity = submarine_movement.get_velocity()
	move_and_slide()

func flip():
	if Global.is_multiplayer && _is_node_owner():
		Global.godot_steam_abstraction.run_remote_function(self, "flip", [])
	
	flipped = !flipped
	emit_signal("sub_flipped")
	for child in get_children():
		if "scale" in child:
			if child.name == "Headlight":
				child.scale = -child.scale
			else:
				child.scale.x = -child.scale.x
		if "position" in child:
			child.position.x = -child.position.x

## Called when cage breaks
func cage_broken():
	collision_shapes.erase($"Cage")
	$"Cage".queue_free()
	$"NavigationObstacle/Cage".queue_free()
	$"Hurtboxes/CageHurtbox".queue_free()
	$"Hurtboxes/BubbleHurtbox".hurt_by_enemy = true

func damaged(damage_amount : float, by : Hurtbox):
	Global.player.camera.shake(3, 0.5)
 
func die():
	Global.player.scale = Vector2(1,1)
	queue_free()

func _on_submarine_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_area"):
		players_inside += 1
		entered_submarine.emit()
		interior_texture.visible = true
		exterior_texture.visible = false

func _on_submarine_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_area"):
		players_inside -= 1
		if players_inside <= 0:
			interior_texture.visible = false
			exterior_texture.visible = true
