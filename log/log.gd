extends Node


func out(text: String):
	var id = "NONE"
	if multiplayer != null:
		id = str(multiplayer.get_unique_id())
	
	print_rich("[b]ID: [/b]" + id + " [b]|[/b] " + text)


func fatal(error: String):
	print_rich("[color=#f74a4a]FATAL:[/color] " + error)
	get_tree().quit(1)
