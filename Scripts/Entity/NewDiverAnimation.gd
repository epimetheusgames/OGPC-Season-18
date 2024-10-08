extends Node2D


@onready var arm_target1: Node2D = $"ArmIkTarget1"
@onready var arm_target2: Node2D = $"ArmIkTarget2"

@onready var leg_target1: Node2D = $"LegIkTarget1"
@onready var leg_target2: Node2D = $"LegIkTarget2"


func _ready() -> void:
	arm_target1 = Util.safeguard_null(arm_target1, "Node2D")
	arm_target2 = Util.safeguard_null(arm_target2, "Node2D")
	
	leg_target1 = Util.safeguard_null(leg_target1, "Node2D")
	leg_target2 = Util.safeguard_null(leg_target2, "Node2D")
