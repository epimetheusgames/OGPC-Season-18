# Coded by Xavier
class_name SubmarineWeaponsModule
extends SubmarineModule

@export var attached_weapon : SubmarineWeapon 

var in_interaction_area : bool = false
var is_being_operated : bool = false

func _ready() -> void:
	super()
	if attached_weapon != null:
		attached_weapon = attached_weapon.instantiate()
		$"SubmarineWeaponSlot".add_child(attached_weapon)

func _physics_process(delta: float) -> void:
	if !Global.player:
		return
	
	if Input.is_action_just_pressed("interact"):
		if Global.player.get_state() != Util.DiverState.OPERATING_MODULE and in_interaction_area: 
			Global.player.set_state(Util.DiverState.OPERATING_MODULE)
			is_being_operated = true
			attached_weapon.is_being_operated = true
		elif Global.player.get_state() == Util.DiverState.OPERATING_MODULE:
			Global.player.set_state(Util.DiverState.IN_SUBMARINE)
			is_being_operated = false
			attached_weapon.is_being_operated = false
	
	if is_being_operated && Global.player.get_state() == Util.DiverState.OPERATING_MODULE:
		Global.player.global_transform = global_transform

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent() is Diver:
		in_interaction_area = true

func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area.get_parent().get_parent() is Diver:
		in_interaction_area = false
