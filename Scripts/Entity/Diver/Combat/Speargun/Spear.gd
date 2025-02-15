class_name Spear
extends BaseBullet

@onready var rope_point: Node2D = $"RopePoint"

var attach_dif: Vector2 = Vector2.ZERO

var attach_body: Node2D = null
var attached: bool = false

func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	super(delta)
	
	if attached and is_instance_valid(attach_body):
		global_position = attach_body.to_global(attach_dif)
		global_rotation = global_position.angle_to_point(attach_body.global_position)

func fire(angle: float) -> void:
	rotation = angle
	velocity = Vector2(speed, 0).rotated(angle)
	attackbox.is_attacking = true

func _on_body_entered(body: Node2D) -> void:
	if attached || body is Spear || body is Diver:
		return
	
	attach_body = body as Node2D
	
	if attach_body:
		attached = true
		attach_dif = attach_body.to_local(global_position)
		velocity = Vector2.ZERO
		
		if Global.verbose_debug:
			print("DEBUG: Spear weapon attached to: ", attach_body.name)
