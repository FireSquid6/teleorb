extends Control

var chatroom_scene = preload("res://chatroom/chatroom.tscn")
var server_scene = preload("res://server_console/server_console.tscn")

func _on_button_pressed():
	Client.connect_to_server($TextEdit.text)
	get_tree().change_scene_to_packed(chatroom_scene)


func _on_button_2_pressed():
	Server.start_server()
	get_tree().change_scene_to_packed(server_scene)
