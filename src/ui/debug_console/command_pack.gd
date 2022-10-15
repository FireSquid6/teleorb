extends Resource
class_name CommandPack


# should be overridden by child objects
# copy and paste me!
func get_commands() -> Array:
	# delete line below
	return []
	
	# template code below:
	return [
		{
			"function": Callable(func(arguments: Dictionary) -> String:
				return ""
				),
			"meta": {
				"name": "command_name",
				"description": "description",
				"arguments": [
					{
						"name": "argument_name",
						"description": "argument_description",
						"possible_values": [
							
						],
						"default_value": "_"
					},
				],
			}
		},
	]

# metadata should look something like the following:
# name: <command-name>
# description: <command-description>
# arguments: [{
#	name: <argument-name>
#	description: <argument-description>
#	possible-values: <possible-values>
#	default-value: <default-value>
# }]
