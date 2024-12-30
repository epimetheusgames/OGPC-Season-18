extends Node2D

func turn_on_efficient():
	if Global.super_efficient:
		$LevelContainer/Level/Waves/Line2D.material = null
		$LevelContainer/Level/Waves/Line2D2.material = null
		$LevelContainer/Level/Waves/Line2D3.material = null
		$LevelContainer/Level/Waves/Line2D4.material = null
		$LevelContainer/Level/Waves/Line2D5.material = null
		$LevelContainer/Level/Waves/Line2D6.material = null
		$LevelContainer/Level/Waves/Line2D7.material = null
		$LevelContainer/Level/Background.material = null
		$LevelContainer/Level/TransBackground.material = null
func _ready():
	Global.current_mission_node = self
	if Global.super_efficient:
		$LevelContainer/Level/Waves/Line2D.material = null
		$LevelContainer/Level/Waves/Line2D2.material = null
		$LevelContainer/Level/Waves/Line2D3.material = null
		$LevelContainer/Level/Waves/Line2D4.material = null
		$LevelContainer/Level/Waves/Line2D5.material = null
		$LevelContainer/Level/Waves/Line2D6.material = null
		$LevelContainer/Level/Waves/Line2D7.material = null
		$LevelContainer/Level/Background.material = null
		$LevelContainer/Level/TransBackground.material = null
