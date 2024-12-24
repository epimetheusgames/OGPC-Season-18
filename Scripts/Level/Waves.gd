# Owned by: carsonetb
extends Node2D

@export var water_rect: Rect2
@export var water_color: Color
@export var k = 0.025
@export var d = 0.05
@export var spread = 0.4
@export var target_height = 0
@export var diver: Diver

@export var spacing := 4.0:
	set(val):
		spacing = val
		if ready_called:
			_ready()

var multiplier = 8
var spring_positions = []
var spring_velocities = []
var boat_index = 20
var ready_called = false

var background_waves = [[8, 0.05, 0], [-8, 0.08, 1.5], [5, 0.12, 1.5], [1, 0.5, 3], [30, 0.0005, 0], [0.5, 0.7, 2]]
#var background_waves = [[100, 0.01, 0]]

var time = 0

func _run_spring(index):
	var x = spring_positions[index].y - target_height;
	var acceleration = -k * x - d * spring_velocities[index]
	
	spring_positions[index].y += spring_velocities[index]
	spring_velocities[index] += acceleration
	
func _ready():
	ready_called = true
	spring_positions = []
	spring_velocities = []
	for i in range($Line2D.polygon.size() - 2):
		spring_positions.append(Vector2(i * spacing, target_height))
		spring_velocities.append(0)

func _process(delta: float) -> void:
	time += delta
	
	#for i in range(spring_positions.size()):
		#_run_spring(i)
	
	#var left_deltas = []
	#var right_deltas = []
	var bg_waves_total = []
	
	for i in range(spring_positions.size()):
		#left_deltas.append(0)
		#right_deltas.append(0)
		bg_waves_total.append(0)
	
	#for j in range(8):
		#for i in range(spring_positions.size()):
			#if i > 0:
				#left_deltas[i] = spread * (spring_positions[i].y - spring_positions[i - 1].y)
				#spring_velocities[i - 1] += left_deltas[i]
			#if i < spring_positions.size() - 1:
				#right_deltas[i] = spread * (spring_positions[i].y - spring_positions[i + 1].y)
				#spring_velocities[i + 1] += right_deltas[i]
				#
		#for i in range(spring_positions.size()):
			#if i > 0:
				#spring_positions[i - 1].y += left_deltas[i]
			#if i < spring_positions.size() - 1:
				#spring_positions[i + 1].y += right_deltas[i]
	
	if diver.global_position.y - 1000 > spring_positions[0].y :
		return 
	
	for i in range(spring_positions.size()):
		for wave in background_waves:
			var amp = wave[0]
			var period = wave[1] * multiplier
			var phase = wave[2] + (time / multiplier) * (amp * amp) * 2
			bg_waves_total[i] += amp * sin(period * (i + phase + diver.global_position.x / spacing))
	
	for i in range(spring_positions.size()):
		$Line2D.polygon[i] = spring_positions[i] + Vector2(diver.global_position.x + 1000 - global_position.x, bg_waves_total[i])
	
	var end_p1 = $Line2D.polygon[-1]
	var end_p2 = $Line2D.polygon[-2]
	$Debug.points = $Line2D.polygon
	$Line2D2.polygon = $Line2D.polygon
	$Line2D3.polygon = $Line2D.polygon
	$Line2D4.polygon = $Line2D.polygon
	$Line2D5.polygon = $Line2D.polygon
	$Line2D6.polygon = $Line2D.polygon
	$Line2D7.polygon = $Line2D.polygon
	
	$Line2D2.polygon[-1] = end_p1 - ($Line2D2.position - $Line2D.position)
	$Line2D2.polygon[-2] = end_p2 - ($Line2D2.position - $Line2D.position)
	$Line2D3.polygon[-1] = end_p1 - ($Line2D3.position - $Line2D.position)
	$Line2D3.polygon[-2] = end_p2 - ($Line2D3.position - $Line2D.position)
	$Line2D4.polygon[-1] = end_p1 - ($Line2D4.position - $Line2D.position)
	$Line2D4.polygon[-2] = end_p2 - ($Line2D4.position - $Line2D.position)
	$Line2D5.polygon[-1] = end_p1 - ($Line2D5.position - $Line2D.position)
	$Line2D5.polygon[-2] = end_p2 - ($Line2D5.position - $Line2D.position)
	$Line2D6.polygon[-1] = end_p1 - ($Line2D6.position - $Line2D.position)
	$Line2D6.polygon[-2] = end_p2 - ($Line2D6.position - $Line2D.position)
	$Line2D7.polygon[-1] = end_p1 - ($Line2D7.position - $Line2D.position)
	$Line2D7.polygon[-2] = end_p2 - ($Line2D7.position - $Line2D.position)
	
	#$StaticBody2D.position = $Line2D.position + $Line2D.polygon[boat_index + 3] - Vector2(0, 0)
	#$StaticBody2D2.position = $Line2D.position + $Line2D.polygon[boat_index + 30] - Vector2(0, 0)
	#
	#if Input.is_action_pressed("left"):
		#boat_index -= 1
	#if Input.is_action_pressed("right"):
		#boat_index += 1
#
#func splash(index, speed):
	#if index >= 0 && index < spring_positions.size():
		#spring_velocities[index] = speed
