class_name MinimalChat
extends PanelContainer

@export var text: RichTextLabel
@export var line_edit: LineEdit
@export var set_default_onready := false

func _ready() -> void:
	text.text = Global.chat_text
	if set_default_onready:
		Global.chat = self
	text.scroll_to_paragraph(text.get_paragraph_count())

	push_debug("Chat initialised at path " + str(get_path()))
	push_debug("Reminder, to prevent debug and error text in chat, disable verbose_debug in root.")

func push_chat(sender: String, message: String, sender_color: String, message_color: String):
	text.scroll_to_paragraph(text.get_paragraph_count())
	text.append_text("[color=" + sender_color + "]" + sender + "[/color]: [color=" + message_color + "]" + message + "[/color]\n")

func push_error(message: String):
	push_chat("System", message, "red", "white")

func push_debug(message: String):
	push_chat("SystemDebug", message, "green", "white")

func push_syserr(message: String):
	push_chat("SystemError", message, "red", "white")
