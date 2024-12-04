## The player of the game.
# Owned by: kaitaobenson

class_name Diver
extends Entity

@onready var diver_movement: DiverMovement = $"Movement"
@onready var diver_animation: DiverAnimation = $"Animation"
@onready var diver_combat: DiverCombat = $"Combat"
@onready var diver_flashlight: DiverFlashlight = $"Flashlight"

@export var water_surface_height: int
@export var water_manager: Node2D

@onready var water_polygon: Polygon2D = water_manager.get_children()[0] if water_manager else null

func _ready() -> void:
	Global.player = self

func _physics_process(delta: float):
	velocity = diver_movement.get_velocity()
	
	var target_angle: float = velocity.angle() + PI/2
	
	var angle_diff: float = angle_difference(rotation, target_angle)
	rotation += clamp(angle_diff * 0.1, -0.1, 0.1)
	
	move_and_slide()

func get_diver_movement() -> DiverMovement:
	return diver_movement
