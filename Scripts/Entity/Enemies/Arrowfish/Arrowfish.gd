class_name ArrowFish
extends Enemy

func _ready() -> void:
	Global.save_load_framework.save_nodes.connect(_on_save)
	state_machine.init(self)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	move_and_slide()
	#print("Current state: " + state_machine.current_state.name)

func _on_save() -> void:
	Global.current_game_save.node_saves.append(NodeSaver.create(Global.current_mission_node, self,
		[
			"global_position",
			"global_rotation",
			"dead_from_save",
		],
		{
			get_path_to($Hurtbox): [
				"health"
			]
		}))
