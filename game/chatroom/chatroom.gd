extends Control


func _ready():
	Chat.connect("message_recieved", _on_new_message)

func _on_button_pressed():
	var message = $TextEdit.text
	Chat.send_message(message)
	$TextEdit.text = ""


func _on_new_message(msg):
	var label: Label = Label.new()
	label.text = msg
	
	$Panel/ScrollContainer/VBoxContainer.add_child(label)
