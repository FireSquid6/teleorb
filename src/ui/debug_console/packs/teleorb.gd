extends CommandPack
class_name TeleorbPack

func get_commands() -> Array:
	# template code below:
	return [
		{
			"function": Callable(func(arguments: Dictionary) -> String:
				var visible = (arguments["visible"] == "true")
				
				var level := Console.get_tree().current_scene as Level
				if level != null:
					var debug_labels: Control = level.get_node("HUD/DebugLabels")
					debug_labels.visible = visible
				
				
				return "Debug overlay visibility set to [color=pink]{0}[/color].".format([arguments["visible"]])
				),
			"meta": {
				"name": "!debug_visibility",
				"description": "sets whether the debug view is visible or not",
				"arguments": [
					{
						"name": "visible",
						"description": "whether the debug overlay is visible or not",
						"possible_values": [
							"true",
							"false"
						],
						"default_value": "false"
					},
				],
			}
		},
	]
