extends Control

var chatroom_scene = preload("res://chatroom/chatroom.tscn")

func _on_button_pressed():
	Client.connect_to_server()
	get_tree().change_scene_to_packed(chatroom_scene)


func _on_button_2_pressed():
	Server.start_server()
