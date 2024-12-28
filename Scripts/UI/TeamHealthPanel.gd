## Displays team info, such as name and health
## Later there can be more things displayed here

class_name TeamInfoPanel
extends PanelContainer

const UPDATE_INTERVAL = 4.0

var divers: Array[Diver]
var display_nodes: Array[BoxContainer]

var timer: float = 0.0

func _ready() -> void:
	for diver: Diver in divers:
		var 
	

func _process(delta: float) -> void:
	timer += delta
	
	if timer >= UPDATE_INTERVAL:
		update_panel()
		timer = 0.0

func update_panel() -> void:
	for i in range(divers.size()):
		var diver: Diver = divers[i]
		var diver_info: PlayerInfo = team_info[i]
		
		if diver.name != diver_info.name:
			diver_info.name = diver.name  # Set it
			
