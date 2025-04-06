## Semi-auto pistol (tranquilizer?)
# Owned by carsonetb

class_name Pistol
extends Gun

@onready var pistol_sprite: AnimatedSprite2D = $"PistolSprite"
@onready var emit_point: Node2D = $"EmitPoint"
@onready var cone_of_fire: ConeOfFire = $"ConeOfFire"
@export var hand1pos: Node2D

func _process(delta: float) -> void:
	super(delta)
	
	if Global.godot_steam_abstraction && Global.is_multiplayer && !Global.player._is_node_owner():
		return
	
	if Global.godot_steam_abstraction && (!Global.is_multiplayer || Global.player._is_node_owner()):
		Global.godot_steam_abstraction.sync_var(self, "position")
		Global.godot_steam_abstraction.sync_var(self, "rotation")

func perform_attack(remote=false, node_name="") -> void:
	super(remote, node_name)
	
	if !remote:
		var rng = RandomNumberGenerator.new()
		node_name = str(rng.randi())
	
	pistol_sprite.play("Shoot")
	
	var bullet: BaseBullet = bullet_scene.instantiate()
	bullet.name = node_name
	add_child(bullet, true)
	
	bullet.global_position = emit_point.global_position
	var shot_angle: float = cone_of_fire.get_shot_angle()
	bullet.fire(shot_angle)
