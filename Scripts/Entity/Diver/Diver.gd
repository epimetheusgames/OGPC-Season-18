## The player of the game.
# Owned by: kaitaobenson

class_name Diver
extends Entity

enum STATE_ENUM {
	SWIMMING,
	IN_SUBMARINE,
	DRIVING_SUBMARINE,
}

var player_state : STATE_ENUM

@onready var diver_movement: DiverMovement = $"Movement"
@onready var diver_animation: DiverAnimation = $"Animation"
@onready var diver_combat: DiverCombat = $"Combat"
@onready var diver_flashlight: DiverFlashlight = $"Flashlight"

@export var water_manager: Node2D

@onready var water_polygon: Polygon2D = water_manager.get_children()[0] if water_manager else null

func _ready() -> void:
	set_state("SWIMMING")
	if !Global.player:
		Global.player = self
	$BuoyancyComponent.waves = water_manager

func _physics_process(_delta: float):
	velocity = diver_movement.get_velocity()
	
	var target_angle: float = velocity.angle() + PI/2
	
	var angle_diff: float = angle_difference(rotation, target_angle)
	rotation += clamp(angle_diff * 0.1, -0.1, 0.1)
	
	move_and_slide()

func get_diver_movement() -> DiverMovement:
	return diver_movement

func set_state(state : String):
	if state == "SWIMMING":
		player_state = STATE_ENUM.SWIMMING
	elif state == "IN_SUBMARINE":
		player_state = STATE_ENUM.IN_SUBMARINE
	elif state == "DRIVING_SUBMARINE":
		player_state = STATE_ENUM.DRIVING_SUBMARINE
	else:
		print("ERROR: Player state " + state + " not found")

func get_state() -> String:
	return STATE_ENUM.keys()[player_state]
