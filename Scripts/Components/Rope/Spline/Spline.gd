extends Node

if !is_on_screen:
		if smoothed_line:
			smoothed_line.visible = false
		line.visible = false
		return
	
	if smoothed_line:
		smoothed_line.visible = true
	else:
		line.visible = true
		



# Generate a cubic hermite spline based on the rope we've already calculated.
func smooth_line():
	if !smoothed_line:
		return
	
	var resoulution_multiplier: float = 4
	var new_smoothed_points: PackedVector2Array = []
	var tangents: PackedVector2Array = []
	
	# Generate tangents ... This is making it a catmull-rom spline.
	# https://en.wikipedia.org/wiki/Cubic_Hermite_spline, Catmull-Rom section.
	for i in range(1, len(line.points) - 1):
		tangents.append((line.points[i + 1] - line.points[i - 1]) / 2.0)
	
	for i in range(1, len(line.points) - 3):
		for big_t in range(0, resoulution_multiplier):
			var t = big_t / resoulution_multiplier
			
			# Massive polynomial, who knows what it means.
			var pos = ((2 * t ** 3) - (3 * t ** 2) + 1) * line.points[i] + \
					  ((t ** 3) - (2 * t ** 2) + t) * tangents[i - 1] + \
					  ((-2 * t ** 3) + (3 * t ** 2)) * line.points[i + 1] + \
					  ((t ** 3) - (t ** 2)) * tangents[i]
			
			new_smoothed_points.append(pos)
	
	smoothed_line.points = new_smoothed_points
