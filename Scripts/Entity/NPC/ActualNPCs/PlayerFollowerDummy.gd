class_name PlayerFollowerDummy
extends CivillianFollower

func get_follow_position() -> Vector2:
    return Global.player.global_position - Vector2.from_angle(Global.player.rotation).normalized() * follow_distance