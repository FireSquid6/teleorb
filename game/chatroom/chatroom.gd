extends Control



func _on_button_pressed():
	var message = $TextEdit.text
	Chat.send_message(message)
