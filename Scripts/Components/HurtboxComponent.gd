## Component for a simple hitbox, contains support for a HealthComponent to be
## attached to it.
class_name HurtboxComponent
extends BaseHitboxComponent

@export_node_path("HealthComponent") var attachable_health_component

func _ready() -> void:
	_init_hurtbox()
	
	# Connect signals
	if hurtbox:
		hurtbox_node.area_entered.connect(_area_entered)
	
	component_name = "HurtboxComponent"
	
func _area_entered(area: Area2D) -> void:
	if attachable_health_component:
		var damage_ammount := 1.0
		if area.get_parent() is Entity:
			var parent: Entity = area.get_parent()
			var attack_box_component: AttackBoxComponent = parent.get_component("AttackBoxComponent")
			if attack_box_component:
				damage_ammount = attack_box_component.damage
		
		get_node(attachable_health_component).take_damage(damage_ammount)
