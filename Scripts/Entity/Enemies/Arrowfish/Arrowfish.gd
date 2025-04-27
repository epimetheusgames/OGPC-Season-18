class_name ArrowFish
extends Enemy

func _ready() -> void:
	Global.save_load_framework.save_nodes.connect(_on_save)
	state_machine.init(self)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	move_and_slide()
	
	if state_machine.current_state != $StateMachine/Aim:
		rotation = Util.better_angle_lerp(rotation, velocity.angle(), 0.8, delta)
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
