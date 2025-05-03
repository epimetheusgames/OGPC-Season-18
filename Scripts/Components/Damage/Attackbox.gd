## Abstract class for dealing damage to Hurtbox
## DON'T ADD THIS TO SCENE TREE
## Use implementations ContinuousAttack and OneShotAttack
# Owned by: kaitaobenson

class_name Attackbox
extends Area2D

enum AttackerType {
	ENEMY,
	PLAYER,
	OTHER, # Should damage both enemy and player
}

@export var attacker_type: AttackerType = AttackerType.OTHER
@export var damage_amount: float = 1.0
@export var knockback_force: float = 0.0

@export var damaging: bool = true

# Signals when it hits a hurtbox
signal hurtbox_hit(hurtbox, Hurtbox)

# Signals when it damages a hurtbox
signal damage_dealt(hurtbox: Hurtbox, damage_amount: float)

# Signals when a hurtbox damaged reaches 0 health
signal killed()

func _ready() -> void:
	var collision: Node2D = get_child(0)
	
	assert(collision is CollisionShape2D || collision is CollisionPolygon2D, 
	"Attackbox has no collision shape node assigned")
	
	if collision is CollisionShape2D:
		collision.debug_color = Color.RED
		collision.debug_color.a = 0.3

func _process(delta: float) -> void:
	if damaging:
		detect_and_damage_hurtboxes()

func detect_and_damage_hurtboxes() -> void:
	pass # Damaging behavior goes here

func damage_hurtbox(hurtbox: Hurtbox) -> void:
	if hurtbox.can_take_damage(self):
		Global.print_debug("DEBUG: Attackbox at path " + str(get_path()) + " damages the hurtbox below.")
		
		hurtbox.damage(damage_amount, self)
		display_number(int(damage_amount), hurtbox.global_position)
		
		damage_dealt.emit(hurtbox, damage_amount)
		
		if hurtbox.health <= 0:  
			killed.emit()


# TODO: Improve this and move it to some global static function probably, w/ object pooling
func display_number(value: int, _position: Vector2) -> void:
	var number = Label.new()
	number.top_level = true
	number.z_index = 50
	number.global_position = _position
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
