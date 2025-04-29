## Semi-auto pistol (tranquilizer?)
# Owned by carsonetb

class_name Pistol
extends Gun

@onready var pistol_sprite: AnimatedSprite2D = $"PistolSprite"
@onready var emit_point: Node2D = $"EmitPoint"
@onready var cone_of_fire: ConeOfFire = $"ConeOfFire"

@onready var gunshot_sounds = $"GunshotSounds"

@export var hand1pos: Node2D

func _ready() -> void:
	super()
	
	use_hand1 = true
	use_hand2 = true

func _process(delta: float) -> void:
	super(delta)
	
	if Global.godot_steam_abstraction && Global.is_multiplayer && !Global.player._is_node_owner():
		return
	
	if Global.godot_steam_abstraction && (!Global.is_multiplayer || Global.player._is_node_owner()):
		Global.godot_steam_abstraction.sync_var(self, "position")
		Global.godot_steam_abstraction.sync_var(self, "rotation")
	
	if gun_state == GunState.AIMING:
		cone_of_fire.spread_angle_degrees -= 5

func perform_attack(remote=false, node_name="") -> void:
	super(remote, node_name)
	
	if !remote:
		var rng = RandomNumberGenerator.new()
		node_name = str(rng.randi())
	
	pistol_sprite.play("Shoot")
	gunshot_sounds.play_random()
	
	var bullet: BaseBullet = bullet_scene.instantiate()
	bullet.name = node_name
	add_child(bullet, true)
	
	bullet.global_position = emit_point.global_position
	var shot_angle: float = cone_of_fire.get_shot_angle()
	bullet.fire(shot_angle)



func get_hand1_pos() -> Vector2:
	return hand1pos.global_position

func get_hand2_pos() -> Vector2:
	return hand1pos.global_position
