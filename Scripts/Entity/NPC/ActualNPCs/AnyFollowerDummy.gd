class_name AnyFollowerDummy
extends CivillianFollower

@export var follows: Node2D

func get_follow_position() -> Vector2:
    if follows:
        return follows.global_position
    Global.print_error("AnyFollowerDummy at path " + str(get_path()) + " has no target to follow. Returning zero vector.")
    return Vector2.ZERO