extends CommandPack
class_name HelperPack


# TODO: add the following commands:
# help - shows a list and description of each command
# clear - clears the console
# scene_restart - restarts the current scene
# scene_goto - goes to a certain scene


func get_commands() -> Array:
	return [
		# help command
		{
			"function": Callable(func(arguments: Dictionary) -> String:
				var output = ''
				for command in Console.commands:
					output += '[color=#bde8a0]{0}[/color] - {1}\n'.format([command["meta"]["name"], command["meta"]["description"]])
				return output
				),
			"meta": {
				"name": ".help",
				"description": "lists all commands",
				"arguments": [
					
				],
			}
		},
		# clear
		{
			"function": Callable(func(arguments: Dictionary) -> String:
				Console.body.clear()
				return ""
				),
			"meta": {
				"name": ".clear",
				"description": "clears all text in the in-game console",
				"arguments": [
				],
			}
		},
		# restart scene
		{
			"function": Callable(func(args := {}) -> String:
				Console.get_tree().reload_current_scene()
				return "Scene at path '{0}' restarted.".format([Console.get_tree().current_scene.scene_file_path])
				),
			"meta": {
				"name": ".restart_scene",
				"description": "restarts the current scene",
				"arguments": [
				],
			}
		},
		# goto scene
		{
			"function": Callable(func(arguments: Dictionary) -> String:
				var scene_path: String = arguments["scene_path"]
				if Console.get_tree().change_scene_to_file(scene_path) == OK:
					return "[color=green]Scene successfully changed to \"{0}\"".format([scene_path])
				
				return "[color=red]Scene change failed.[/color]"
				),
			"meta": {
				"name": ".change_scene",
				"description": "Changes the scene to the argument scene_path",
				"arguments": [
					{
						"name": "scene_path",
						"description": "the path to the scene the game will transfer to. No spaces",
						"possible_values": [
						],
						"default_value": "_"
					},
				],
			}
		},
	]
