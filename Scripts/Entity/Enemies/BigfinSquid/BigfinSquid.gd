class_name BigfinSquid
extends Enemy


@onready var arms: Array[Line2D] = [$RightFrontArm, $LeftFrontArm, $RightBackArm, $LeftBackArm]
@onready var ropes: Array[VerletRope] = [$RightFrontArmRope, $LeftFrontArmRope, $RightBackArmRope, $LeftBackArmRope]
@onready var limbs: Array[Node2D]
var targets: Array[Node2D] = []
var end_targets: Array[Node2D] = []
var dead := false

func _ready() -> void:
	super()
	
	state_machine.init(self)
	
	await get_tree().create_timer(0.1).timeout
	
	var anim := Global.player.diver_animation
	limbs = [anim.arm1, anim.arm2, anim.leg1, anim.leg2]
	
	for i in range(ropes.size()):
		var rope := ropes[i]
		
		var drawer := RopeLineDrawer.new()
		drawer.rope = rope
		drawer.resolution_multiplier = 6
		drawer.smoothing_on = true
		drawer.z_index = arms[i].z_index
		drawer.width = 8
		drawer.default_color = arms[i].default_color
		add_child(drawer)
		
		var target = Node2D.new()
		targets.append(target)
		
		var end_target = Node2D.new()
		end_targets.append(end_target)
		
		rope.rope_drawer = drawer
		rope.start_anchor_node = target
		rope.start_pos_on = true
		rope.end_anchor_node = end_target
		rope.end_pos_on = true
		rope.damping = 0.95

func _process(delta: float) -> void:
	if dead:
		return
	
	super(delta)
	
	var closest_player := get_closest_player()
	state_machine.process_physics(delta)
	move_and_slide()
	
	for rope in ropes:
		rope.is_on_screen = $VisibleOnScreenNotifier2D.is_on_screen()
		
	rotation = velocity.angle() + PI / 2.0
	
	for i in range(targets.size()):
		ropes[i].is_on_screen = $VisibleOnScreenNotifier2D.is_on_screen()
		ropes[i].gravity = -velocity.normalized() * 10
		targets[i].global_position = arms[i].points[1].rotated(arms[i].global_rotation) + arms[i].global_position
		
		if closest_player:
			end_targets[i].global_position = limbs[i].global_position
			ropes[i].end_pos_on = true
		else:
			ropes[i].end_pos_on = false
	
	if closest_player && \
	   (((Global.godot_steam_abstraction && Global.is_multiplayer && node_owner == closest_player.node_owner) || \
		!Global.is_multiplayer || !Global.godot_steam_abstraction) && \
		closest_player.global_position.distance_squared_to(global_position) < 1000 ** 2
	):
		closest_player.global_position += (global_position - closest_player.global_position).normalized() * 5 * delta * 60

func _on_hurtbox_died() -> void:
	for rope in ropes:
		rope.end_pos_on = false
	dead = true
