extends Control

@export var _text_edit: TextEdit


func _on_direct_connection_pressed() -> void:
	var text = _text_edit.text
	if text == "":
		text = "127.0.0.1"
	Client.connect_to_server(text)
	World.main.start_game()

func _on_create_server_pressed() -> void:
	Server.start_server("")
	World.main.start_game()
