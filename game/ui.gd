extends Control

func _on_button_pressed():
	var text = $TextEdit.text
	if text == "":
		text = "127.0.0.1"
	Client.connect_to_server(text)
	World.main.start_game()


func _on_button_2_pressed():
	Server.start_server()
	World.main.start_game()
