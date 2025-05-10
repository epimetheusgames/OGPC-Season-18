extends BaseItem

func _ready() -> void:
	super()
	
	Global.player.diver_stats.hurtbox.heal(25)
	queue_free()
