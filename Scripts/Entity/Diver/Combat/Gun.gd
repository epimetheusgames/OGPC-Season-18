# Base class for guns
## Owned by: kaitaobenson

class_name Gun
extends Weapon

enum GunState {
	HOLDING,
	AIMING,
}

@export var animation_node: AnimatedSprite2D
@export var bullet_scene: PackedScene

@export var dist_from_head: float = 100.0

@export var knockback: float = 10.0

var flipped: bool = false

var gun_state := GunState.HOLDING

func _ready() -> void:
	super()

func _process(delta: float) -> void:
	super(delta)
	
	var dir: Vector2 = mouse_pos - head_pos
	global_position = head_pos + dir.normalized() * dist_from_head
	
	var rot: float = head_pos.angle_to_point(mouse_pos)
	global_rotation = rot
	
	var deg_rot: float = Util.normalize_angle_degrees(rad_to_deg(rot))
	flipped = deg_rot > 90 && deg_rot < 270
	
	if flipped:
		scale.y = -1
	else:
		scale.y = 1
