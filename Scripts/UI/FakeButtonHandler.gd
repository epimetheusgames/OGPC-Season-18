extends ColorRect

var disabled:bool = false
signal button_down
@onready var textBox:RichTextLabel = get_node("text")
@onready var currentColor:Color = color
var text:String

func isHovering(asize,pos):
	return Rect2(pos, asize).has_point(get_global_mouse_position())
	
func _input(event):
	if ((event is InputEventMouseButton and event.button_index==1) or event is InputEventMouseMotion):
		var hasPressed = event is InputEventMouseButton and event.button_index==1 and event.is_pressed()
		if(isHovering(self.size,self.global_position)):
			if(hasPressed and !disabled):
				button_down.emit()
func _process(_delta):
	#if(isHovering())
	textBox.text = text

	
