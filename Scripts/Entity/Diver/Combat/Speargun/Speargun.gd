# Lightweight gun powered by rubbers or air canisters,
# used for spearing small / medium fish
## Owned by: kaitaobenson

class_name Speargun
extends Gun

@onready var emit_point: Node2D = $"EmitPoint"
@onready var cone_of_fire: ConeOfFire = $"EmitPoint/ConeOfFire"
@onready var gun_animation: AnimatedSprite2D = $"GunAnimation"

@onready var gunshot_sounds: AudioVariationPlayer = $"GunshotSounds"
@onready var reload_sounds: AudioVariationPlayer = $"ReloadSounds"

@onready var hand1_point: Node2D = $"Hand1Point"
@onready var hand2_point: Node2D = $"Hand2Point"

func _ready() -> void:
	super()
	reload_finish.connect(reload_animation)

func _process(delta: float) -> void:
	super(delta)
	
	if Global.godot_steam_abstraction && Global.is_multiplayer && !Global.player._is_node_owner():
		return
	
	if gun_state == GunState.HOLDING:
		use_hand1 = false
		use_hand2 = false
		dist_from_head = 60
	else:
		use_hand1 = true
		use_hand2 = true
		dist_from_head = 50
	
	if Global.godot_steam_abstraction && (!Global.is_multiplayer || Global.player._is_node_owner()):
		Global.godot_steam_abstraction.sync_var(self, "position")
		Global.godot_steam_abstraction.sync_var(self, "rotation")


func reload_animation() -> void:
	reload_sounds.play_random()
	gun_animation.play("Idle")

func get_hand1_pos() -> Vector2:
	if gun_state == GunState.HOLDING:
		return hand1_point.global_position
	else:
		return hand2_point.global_position

func get_hand2_pos() -> Vector2:
	if gun_state == GunState.HOLDING:
		return hand2_point.global_position
	else:
		return hand1_point.global_position

func perform_attack(remote=false, node_name="") -> void:
	super(remote, node_name)
	
	if !remote:
		var rng = RandomNumberGenerator.new()
		node_name = str(rng.randi())
	
	var new_spear: Spear = bullet_scene.instantiate()
	new_spear.name = node_name
	add_child(new_spear, true)
	
	new_spear.global_position = emit_point.global_position
	new_spear.global_rotation = global_rotation
	
	gun_animation.play("Shoot")
	gunshot_sounds.play_random()
	
	var angle: float = cone_of_fire.get_shot_angle()
	new_spear.fire(angle)
	"""
	var new_rope := VerletRope.new()
	new_rope.component_container = self.get_path()
	new_rope.start_pos_on = true
	new_rope.start_anchor_node = emit_point
	new_rope.end_pos_on = true
	new_rope.end_anchor_node = new_spear.rope_point
	
	add_child(new_rope)
	
	var new_rope_drawer := RopeLineDrawer.new()
	add_child(new_rope_drawer)
	new_rope_drawer.rope = new_rope
	"""
	#print_tree_pretty()
	var force: Vector2 = Util.angle_to_vector_radians(global_rotation + PI, knockback)
	Global.player.diver_movement.knockback(force)
	
	if Global.godot_steam_abstraction:
		Global.godot_steam_abstraction.run_remote_function(self, "spawn_bullet", [])
