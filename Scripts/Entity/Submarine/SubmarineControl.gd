class_name SubmarineControlModule
extends SubmarineModule

@onready var diver = Global.player

var in_interaction_area : bool = false

func _physics_process(delta: float) -> void:
	if !diver:
		return
	
	if Input.is_action_just_pressed("interact"):
		if diver.get_state() != Util.DiverState.DRIVING_SUBMARINE and in_interaction_area: 
			diver.set_state(Util.DiverState.DRIVING_SUBMARINE)
		elif diver.get_state() == Util.DiverState.DRIVING_SUBMARINE:
			diver.set_state(Util.DiverState.IN_SUBMARINE)

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent() is Diver:
		in_interaction_area = true

func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area.get_parent().get_parent() is Diver:
		in_interaction_area = false
