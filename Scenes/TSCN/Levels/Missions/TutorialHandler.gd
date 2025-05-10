extends MissionRoot

enum State {
	START,
}

var state := State.START
@onready var dialog: NPC = $LevelContainer/TutorialDailog

func _ready():
	super._ready()
	Global.dialog_core.play_dialog("Hello, welcome to the Tutorial.", 5, null)
