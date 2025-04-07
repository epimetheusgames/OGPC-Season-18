class_name ArrowFish
extends Enemy

@onready var state_machine: StateMachine = $"StateMachine"

func _ready() -> void:
	state_machine.init(self)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	move_and_slide()
	#print("Current state: " + state_machine.current_state.name)

func _on_save() -> void:
	Global.current_game_save.node_saves.append(NodeSaver.create(Global.current_mission_node, self,
		[
			"position",
			"rotation",
		],
		{
			get_path_to($Hurtbox): [
				"health"
			]
		}))
