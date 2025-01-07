extends TextureRect
@export var notif_bar_speed: float
@onready var default_size: Vector2 = get_node("NotifBar").size
@onready var notif_bar = get_node("NotifBar")
@onready var efficieny_thing = Global.root_node

var t = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(self.visible):
		t+=delta*notif_bar_speed
		notif_bar.size = default_size.lerp(Vector2(0,default_size.y),t)
		if(notif_bar.size.x<=0):
			self.visible = false
		return
	if(efficieny_thing):
		if(Global.current_mission_node!=null&&!efficieny_thing.super_efficient):
			if(Engine.get_frames_per_second()<=efficieny_thing.super_efficient_auto_enable_maximum):
				efficieny_thing.super_efficient = true
				self.visible = true
				notif_bar.size = default_size
				t=0
