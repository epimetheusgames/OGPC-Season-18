extends TextureRect
@export var notif_bar_speed:float
@onready var default_size := self.size

var t = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(self.visible):
		t+=delta*notif_bar_speed
		self.size = default_size.lerp(Vector2(0,default_size.y),t)
		if(self.size.x<=0):
			self.visible = false
		return
	if(Global.current_mission_node!=null&&!get_parent().super_efficient):
		if(Engine.get_frames_per_second()<=get_parent().super_efficient_auto_enable_maximum):
			get_parent().super_efficient = true
			self.visible = true
			t=0
			
