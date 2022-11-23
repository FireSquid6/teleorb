# an easy way to extend the commands offered by the cheat console
# simply extent the get_commands() method, and
class_name CommandPack
extends Resource



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
