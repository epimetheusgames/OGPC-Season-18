## Component for a simple hitbox, contains support for a HealthComponent to be
## attached to it.
class_name HurtboxComponent
extends BaseComponent

@export_node_path("Area2D") var hurtbox
@export_node_path("HealthComponent") var attachable_health_component

var hurtbox_node: Area2D

func _ready() -> void:
	if hurtbox:
		hurtbox_node = get_node(hurtbox)
		
		# 2 = 0100 in binary (see collision mask dataset in GDSCRIPTRULES.md)
		hurtbox_node.collision_mask = 2
		
		# Connect signals
		hurtbox_node.area_entered.connect(_area_entered)
	
	component_name = "HurtboxComponent"

func _process(delta: float) -> void:
	if !hurtbox:
		print("WARNING: HurtboxComponent at path " + str(get_path()) + " requires a hurtbox (Area2D) attached to it.")
		return
	
func _area_entered(area: Area2D) -> void:
	if attachable_health_component:
		var damage_ammount := 1.0
		if area.get_parent() is Entity:
			var parent: Entity = area.get_parent()
			var attack_box_component = parent.get_component("AttackBoxComponent")
			if attack_box_component:
				damage_ammount = attack_box_component.damage
		
		get_node(attachable_health_component).take_damage(damage_ammount)
