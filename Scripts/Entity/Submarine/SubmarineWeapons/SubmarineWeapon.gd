# Coded by Xavier
## Base class for submarine weapons

class_name SubmarineWeapon 
extends Node2D

@onready var emission_point = get_node("ProjectileEmissionPoint")

# Subclass dependent variables
@export var projectile_scene : PackedScene
@export var rotation_range : float
@export var rotation_speed : float
@export var shot_cooldown : float

var max_rotation : float
var min_rotation : float
var target_rot : float

var shot_timer : Timer
var passive_decrease_timer : Timer

var is_being_operated := false

var in_rotation_range := true

var shot_timer_over := true

# Heat stuff
var heat := 0.0 # Max heat 100
var passive_heat_drain := false
var cooling := false
var overheating := false
@export var heat_increase_per_shot : float
@export var passive_decrease_cooldown : float # Amount of time before passive heat decrease begins
@export var passive_heat_decrease_per_sec : float
@export var cooling_heat_decrease_per_sec : float
@export var overheat_heat_decrease_per_sec : float

## NOTE: If we end up having a range that goes above 180 (PI) or -180 (-PI) (eg. min = 160, max = 200) then we might have some clamping issues
func _ready() -> void:
	max_rotation = rotation_degrees + rotation_range/2
	min_rotation = rotation_degrees - rotation_range/2
	print(max_rotation)
	print(min_rotation)
	# common kai W code
	shot_timer = Timer.new()
	shot_timer.one_shot = true
	add_child(shot_timer)
	shot_timer.connect("timeout", _on_shot_cooldown_timeout)
	
	passive_decrease_timer = Timer.new()
	passive_decrease_timer.one_shot = true
	add_child(passive_decrease_timer)
	passive_decrease_timer.connect("timeout", _on_passive_decrease_timer_timeout)

func _on_shot_cooldown_timeout() -> void:
	shot_timer_over = true

func _on_passive_decrease_timer_timeout() -> void:
	passive_heat_drain = true

func _physics_process(delta: float) -> void:
	if passive_heat_drain:
		heat -= passive_heat_decrease_per_sec * delta
		if heat <= 0:
			heat = 0
			passive_heat_drain = false
	elif cooling:
		heat -= cooling_heat_decrease_per_sec * delta
		if heat <= 0:
			heat = 0
			cooling = false
	elif overheating:
		heat -= overheat_heat_decrease_per_sec * delta
		if heat <= 0:
			heat = 0
			overheating = false
	
	if is_being_operated:
		if Input.is_action_just_pressed("reload"):
			# Enter active cooling state
			cooling = true
		
		if Input.is_action_just_pressed("attack"):
			attack()
		
		var mouse_vector_angle = (get_global_mouse_position()-global_position).angle() - get_parent().global_rotation
		if clamp(rad_to_deg(mouse_vector_angle), min_rotation, max_rotation) == rad_to_deg(mouse_vector_angle):
			target_rot = mouse_vector_angle
		
		rotation = Util.better_angle_lerp(rotation, target_rot, .2, delta)

func get_mouse_input_vector() -> Vector2:
	return (Vector2(DisplayServer.mouse_get_position()) - global_position).normalized()

func attack():
	# Carson's anti nesting stuff
	if !shot_timer_over or cooling or overheating:
		return
	if heat >= 100:
		overheating = true
	
	shot_timer_over = false
	passive_heat_drain = false
	heat += heat_increase_per_shot
	
	fire()
	
	shot_timer.start(shot_cooldown)
	passive_decrease_timer.start(passive_decrease_cooldown)

func fire():
	pass # Override
