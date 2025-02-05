# Coded by Xavier
class_name SubmarineWeaponsModule
extends SubmarineModule

@export var attached_weapon : SubmarineWeapon 
@onready var diver = Global.player

var in_interaction_area : bool = false
var is_being_operated : bool = false

func _ready() -> void:
	if attached_weapon != null:
		attached_weapon = attached_weapon.instantiate()
		$"SubmarineWeaponSlot".add_child(attached_weapon)

func _physics_process(delta: float) -> void:
	if !diver:
		return
	
	if Input.is_action_just_pressed("interact"):
		if diver.get_state() != Util.DiverState.OPERATING_MODULE and in_interaction_area: 
			diver.set_state(Util.DiverState.OPERATING_MODULE)
			is_being_operated = true
			attached_weapon.is_being_operated = true
		elif diver.get_state() == Util.DiverState.OPERATING_MODULE:
			diver.set_state(Util.DiverState.IN_SUBMARINE)
			is_being_operated = false
			attached_weapon.is_being_operated = false
	
	if is_being_operated && diver.get_state() == Util.DiverState.OPERATING_MODULE:
		diver.global_transform = global_transform

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent() is Diver:
		in_interaction_area = true

func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area.get_parent().get_parent() is Diver:
		in_interaction_area = false
