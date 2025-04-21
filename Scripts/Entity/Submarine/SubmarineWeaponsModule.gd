# Coded by Xavier
class_name SubmarineWeaponsModule
extends SubmarineModule

@export var attached_weapon : PackedScene

var in_interaction_area : bool = false
var is_being_operated : bool = false

func _ready() -> void:
	super()
	if attached_weapon != null:
		var weapon : Node2D = attached_weapon.instantiate()
		$"SubmarineWeaponSlot".add_child(weapon)
		
		var base : Sprite2D = Sprite2D.new()
		base.scale = Vector2(.03,.03)
		base.texture = weapon.base_texture
		$"SubmarineWeaponSlot".add_child(base)

func _physics_process(delta: float) -> void:
	if !Global.player:
		return
	
	if Input.is_action_just_pressed("interact"):
		if Global.player.get_state() != Diver.DiverState.OPERATING_MODULE and in_interaction_area: 
			Global.player.set_state(Diver.DiverState.OPERATING_MODULE)
			is_being_operated = true
			attached_weapon.is_being_operated = true
		elif Global.player.get_state() == Diver.DiverState.OPERATING_MODULE:
			Global.player.set_state(Diver.DiverState.IN_SUBMARINE)
			is_being_operated = false
			attached_weapon.is_being_operated = false
	
	if is_being_operated && Global.player.get_state() == Diver.DiverState.OPERATING_MODULE:
		Global.player.global_transform = global_transform

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent() is Diver:
		in_interaction_area = true

func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area.get_parent().get_parent() is Diver:
		in_interaction_area = false
