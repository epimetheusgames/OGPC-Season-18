class_name SubmarineControlModule
extends SubmarineModule

var in_interaction_area : bool = false

func _physics_process(delta: float) -> void:
	if !Global.player:
		return
	
	if Input.is_action_just_pressed("interact"):
		if Global.player.get_state() != Diver.DiverState.DRIVING_SUBMARINE and in_interaction_area: 
			Global.player.set_state(Diver.DiverState.DRIVING_SUBMARINE)
		elif Global.player.get_state() == Diver.DiverState.DRIVING_SUBMARINE:
			Global.player.set_state(Diver.DiverState.IN_SUBMARINE)

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_area"):
		in_interaction_area = true

func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_area"):
		in_interaction_area = false
