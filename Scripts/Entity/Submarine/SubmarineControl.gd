extends SubmarineModule

@onready var diver = Global.player

var in_control_area : bool = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and in_control_area:
		if diver.get_state() == Util.DiverState.IN_SUBMARINE: 
			diver.set_state(Util.DiverState.DRIVING_SUBMARINE)
		elif diver.get_state() == Util.DiverState.DRIVING_SUBMARINE:
			diver.set_state(Util.DiverState.IN_SUBMARINE)


func _on_control_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Diver:
		in_control_area = true

func _on_control_area_area_exited(area: Area2D) -> void:
	if area.get_parent() is Diver:
		in_control_area = false
