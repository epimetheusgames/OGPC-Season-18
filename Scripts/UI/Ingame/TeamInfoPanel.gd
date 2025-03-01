## Displays team info, such as name and health
## Later there can be more things displayed here

class_name TeamInfoPanel
extends PanelContainer


@onready var container: BoxContainer = $"MarginContainer/VBox"
@onready var divers: Array[Node] = Global.player.get_parent().get_children()

var health_text_array: Array[RichTextLabel]
var timer: float = 0.0

func _ready() -> void:
	# Containers will be added dynamically later.
	for child in container.get_children():
		child.free()
	
	for diver: Diver in divers:
		var diver_name: String = diver.get_diver_username()
		var diver_health: int = round(diver.get_diver_health())
		
		var new_hbox := HBoxContainer.new()
		new_hbox.custom_minimum_size = Vector2(0, 30)
		container.add_child(new_hbox)
		
		var new_diver_name_text := RichTextLabel.new()
		new_diver_name_text.text = diver_name
		new_diver_name_text.custom_minimum_size = Vector2(160, 0)
		new_diver_name_text.scroll_active = false
		new_hbox.add_child(new_diver_name_text)
		#new_diver_name_text.size = Vector2(20, 20)
		
		var new_separator := VSeparator.new()
		new_separator.add_theme_constant_override("Separation", 10)
		new_hbox.add_child(new_separator)
		
		var new_health_text := RichTextLabel.new()
		
		new_health_text.text = str(diver_health) + "%"
		new_health_text.custom_minimum_size = Vector2(100, 0)
		new_health_text.scroll_active = false
		new_hbox.add_child(new_health_text)
		
		health_text_array.append(new_health_text)

func _process(_delta: float) -> void:
	if !Global.is_multiplayer:
		visible = false
	
	var to_remove: Array[int] 
	
	for i in range(divers.size()):
		if !is_instance_valid(divers[i]):
			to_remove.append(i)
			continue

		var diver: Diver = divers[i]
		var health_text: RichTextLabel = health_text_array[i]
		
		health_text.text = str(diver.get_diver_health()) + "%"

	for index in to_remove:
		divers.remove_at(index)
		
