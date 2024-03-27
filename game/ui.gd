extends Control

@onready var main: Main = get_parent()

func _on_button_pressed():
	Client.connect_to_server($TextEdit.text)
	main.start_game()


func _on_button_2_pressed():
	Server.start_server()
	main.start_game()
