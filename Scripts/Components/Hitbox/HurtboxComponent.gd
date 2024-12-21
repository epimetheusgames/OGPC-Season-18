## Component for a simple hitbox, has support for a HealthComponent to be
## attached to it.
# Owned by: carsonetb
class_name HurtboxComponent
extends BaseHitboxComponent

@export var hitbox_type: HITBOX_TYPE
@export var has_knockback: bool = true
@export_node_path("HealthComponent") var attachable_health_component
@export_node_path("AttackBoxComponent") var attack_box_to_exclude

signal damage_taken(damage_ammount: int)

func _ready() -> void:
	super._ready_base_component()
	_base_hitbox_ready()  # TODO: fix this
	
	# Connect signals
	if hurtbox:
		hurtbox_node.area_entered.connect(_area_entered)
		
		# Set to zero because we don't want anyone getting hurt by our hurtbox.
		hurtbox_node.collision_layer = 0
	
	if hitbox_type == HITBOX_TYPE.PLAYER:
		hurtbox_node.collision_mask = Global.bitmask_conversion["Player Hurtbox / Enemy Attackbox"]
	if hitbox_type == HITBOX_TYPE.ENEMY:
		hurtbox_node.collision_mask = Global.bitmask_conversion["Player Attackbox / Enemy Hurtbox"]
	if hitbox_type == HITBOX_TYPE.ENTITY_INTERACT:
		hurtbox_node.collision_mask = Global.bitmask_conversion["Interaction"]


func _area_entered(area: Area2D) -> void:
	if not attachable_health_component:
		return
	
	# Kinda silly
	var damage_ammount := 1.0
	var parent = area.get_parent()
	if !(parent is Entity):
		parent = parent.get_parent()
	if !(parent is Entity):
		print("WARNING: Hurtbox entered by area at path " + str(area.get_path()) + ", which doesn't have a parent or grandparent that is of type Entity. This will not be detected.")
		return
	
	parent = parent as Entity
	
	# Take damage on all clients.
	if Global.is_multiplayer && parent._is_node_owner():
		Global.godot_steam_abstraction.run_remote_function(self, "_area_entered", [str(area.get_path())], true)
	
	if parent is Entity:
		var attack_box_component: AttackBoxComponent = parent.get_component("AttackBoxComponent")
		
		if attack_box_component && ((!attack_box_to_exclude) || attack_box_component != get_node(attack_box_to_exclude)):
			damage_ammount = attack_box_component.damage
			var container: Entity = get_node(component_container)
			var other_container = attack_box_component.get_node(attack_box_component.component_container)
			var other_container_position = other_container.position
			var direction = (container.position - other_container_position).normalized()
			
			container.set_new_velocity(direction * attack_box_component.knockback_velocity)
			
			if container is Diver:
				container.get_diver_movement().velocity = container.velocity
	
	get_node(attachable_health_component).take_damage(damage_ammount)
	damage_taken.emit(damage_ammount)
