## Component for a simple hitbox, contains support for a HealthComponent to be
## attached to it.
class_name HurtboxComponent
extends BaseHitboxComponent

@export_node_path("HealthComponent") var attachable_health_component
@export_node_path("AttackBoxComponent") var attack_box_to_exclude

signal damage_taken(damage_ammount: int)

func _ready() -> void:
	_init_hurtbox()
	
	# Connect signals
	if hurtbox:
		hurtbox_node.area_entered.connect(_area_entered)
		
		# Set to zero because we don't want anyone getting hurt by our hurtbox.
		hurtbox_node.collision_layer = 0
	
	component_name = "HurtboxComponent"
	
func _area_entered(area: Area2D) -> void:
	if attachable_health_component:
		var damage_ammount := 1.0
		var parent: Entity = area.get_parent()
		if parent is Entity:
			var attack_box_component: AttackBoxComponent = parent.get_component("AttackBoxComponent")
			if attack_box_component && ((!attack_box_to_exclude) || attack_box_component != get_node(attack_box_to_exclude)):
				damage_ammount = attack_box_component.damage
				var container = get_node(component_container)
				var other_container_position = attack_box_component.get_node(attack_box_component.component_container).position
				var direction = (container.position - other_container_position).normalized()
				container.velocity = direction * attack_box_component.knockback_velocity
				
				if container is Diver:
					container.get_diver_movement().velocity = container.velocity
		
		get_node(attachable_health_component).take_damage(damage_ammount)
		damage_taken.emit(damage_ammount)
