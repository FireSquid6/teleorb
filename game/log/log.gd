extends Node


func out(text: String):
	var id = "NONE"
	if multiplayer != null:
		id = str(multiplayer.get_unique_id())
	
	print_rich("[b]ID: [/b]" + id + " [b]|[/b] " + text)
	
