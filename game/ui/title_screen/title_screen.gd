extends Control

@export var _text_edit: TextEdit

var _level: String = "001-002-003-004|004-001-002-003|003-004-001-002|002-003-004-001"

func _on_direct_connection_pressed() -> void:
	var text = _text_edit.text
	if text == "":
		text = "127.0.0.1"
	Client.connect_to_server(text)
	World.main.start_game(_level)

func _on_create_server_pressed() -> void:
	Server.start_server("")
	World.main.start_game(_level)
