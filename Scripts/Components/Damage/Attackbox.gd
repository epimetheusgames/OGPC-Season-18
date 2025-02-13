## Abstract class for dealing damage to Hurtbox
# Owned by: kaitaobenson

class_name Attackbox
extends Area2D

enum AttackerType {
	ENEMY,
	PLAYER,
	OTHER,
}

@export var attacker_type: AttackerType = AttackerType.OTHER
@export var damage_amount: float = 1.0

# Signals when it hits a hurtbox
signal hurtbox_hit(hurtbox, Hurtbox)

# Signals when it damages a hurtbox
signal damage_dealt(hurtbox: Hurtbox, damage_amount: float)

# Signals when a hurtbox damaged reaches 0 health
signal killed()

func _ready() -> void:
	var collision: CollisionShape2D = get_child(0)
	collision.debug_color = Color.RED
	collision.debug_color.a = 0.3

func _process(delta: float) -> void:
	var areas: Array[Area2D] = get_overlapping_areas()
	
	for area in areas:
		if area is Hurtbox:
			var hurtbox: Hurtbox = area
			emit_signal("hurtbox_hit", hurtbox)

func damage_hurtbox(hurtbox: Hurtbox) -> void:
	if hurtbox.can_take_damage(self):
		
		hurtbox.damage(damage_amount)
		display_number(damage_amount, hurtbox.global_position)
		emit_signal("damage_dealt", damage_amount)
		
		if hurtbox.health - damage_amount <= 0:
			emit_signal("killed")

func display_number(value: int, position: Vector2) -> void:
	var number = Label.new()
	number.top_level = true
	number.z_index = 50
	number.global_position = position
	number.text = str(value)
	
	number.label_settings = LabelSettings.new()
	number.label_settings.font = load("res://Assets/Fonts/Geo-Italic.ttf")
	number.label_settings.font_size = 80
	number.label_settings.font_color = Color.FIREBRICK
	
	add_child(number)
	
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(number, "position:y", number.position.y - 100, 0.8).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(number, "modulate:a", 0, 0.8).set_trans(Tween.TRANS_QUAD)
	
