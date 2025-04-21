extends HSlider

var last_value:int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# sliders are super sped, value changed signal just doesnt work for whatever reason
	if(last_value!=self.value):
		value_changed.emit()
	last_value = self.value
