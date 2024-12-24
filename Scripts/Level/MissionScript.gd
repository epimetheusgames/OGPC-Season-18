extends Node2D


func _ready():
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
