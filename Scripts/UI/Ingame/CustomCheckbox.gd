## It has a texture you can set! lol
## Used for dev panel

class_name CustomCheckbox
extends Button

@export var checked_texture: CompressedTexture2D = load("res://Assets/Art/UI/CheckBox.png")
@export var unchecked_texture: CompressedTexture2D = load("res://Assets/Art/UI/EmptyBox.png")

@export var checked: bool = false

func _ready() -> void:
	update_texture()
	
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	checked = !checked
	update_texture()

func update_texture() -> void:
	if checked:
		icon = checked_texture
	else:
		icon = unchecked_texture

func is_checked() -> bool:
	return checked

func set_checked(_checked: bool) -> void:
	self.checked = _checked
