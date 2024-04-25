extends Object
class_name ServerVars

# first is the environment variable name. Second is the name used for server vars. Third is the default

var var_names = [
	["TELEORB_SERVER_ENABLED", "enabled", "false"],
	["TELEORB_SERVER_LEVEL", "level", "000-000-000-000|001-001-001-001|002-002-002-002|003-003-003-003"]
]

var vars := {}

func _init():
	for var_name in var_names:
		if OS.get_environment(var_name[0]) == "":
			vars[var_name[1]] = vars[var_name[2]]
		else:
			vars[var_name[1]] = OS.get_environment(var_name[0])


func get_value(name: String) -> String:
	if vars.has(name):
		return vars[name]
	return ""


func set_value(name: String, value: String) -> void:
	vars[name] = value

