extends CanvasLayer


var key = KEY_F12
@export var command_packs: Array[CommandPack] = []
@export var only_show_if_debug_mode: bool = true
signal unfocused()
signal focused()

@onready var body: RichTextLabel = $DebugConsole/Panel/VBoxContainer/Body
@onready var edit: LineEdit = $DebugConsole/Panel/VBoxContainer/Edit/LineEdit
@onready var edit_display: RichTextLabel = $DebugConsole/Panel/VBoxContainer/Edit
var pre_body := ''
var commands := []
var closed := false
var console_text = ''


func _ready():
	visible = false
	body.clear()
	body.append_text(pre_body)
	
	if (!OS.is_debug_build()) and only_show_if_debug_mode:
		closed = true
	
	# add command packs
	for pack in command_packs:
		pack = pack as CommandPack
		commands.append_array(pack.get_commands())


func _input(event):
	if !closed:
		event = event as InputEventKey
		if event:
			if event.physical_keycode == key and event.pressed:
				visible = !visible
				if visible:
					emit_signal("focused")
					edit.grab_focus()
				else:
					emit_signal("unfocused")


# prints both to the stdout and the rich text label
# it's recommended you do Console.output() instead of print() or print_rich()
func output(text: String, use_bbcode: bool = true) -> void:
	console_text += "\n"+text
	
	if use_bbcode:
		print_rich(text)
	else:
		print(text)
	
	if body:
		body.append_text("\n"+text)
	else:
		pre_body += "\n"+text


func run_command(text: String) -> String:
	# parse the text
	var argument_strings: Array = text.split(" ")
	var command_name: String = argument_strings[0]  
	argument_strings.remove_at(0)
	
	# find the command
	var command = get_command(command_name)
	
	if !command.has("null"):
		var meta: Dictionary = command["meta"]
		var function: Callable = command["function"]
		
		# get argument values
		var arguments := {}
		for argument_couples in argument_strings:
			var split: Array = argument_couples.split("=")
			if len(split) == 2:
				arguments[split[0]] = split[1]
			else:
				return "[color=red]Argument [color=white]\"{0}\"[/color] not given a value. If you want to use an argument's default value, simply do not specify it.[/color]".format([split[0]])
		
		# add any missing arguments their default value
		for argument in meta["arguments"]:
			argument = argument as Dictionary
			
			if !arguments.has(argument["name"]):
				arguments[argument["name"]] = argument["default_value"]
		
		# run the function
		var output = function.call(arguments)
		return output
	
	return '[color=red]Command [color=white]"{0}"[/color] not recognized[/color]'.format([command_name])


func get_command(name: String) -> Dictionary:
	for command in commands:
		command = command as Dictionary
		if command["meta"]["name"] == name:
			return command
	return {
		"null": true
	}


# metadata should look something like the following:
# name: <command-name>
# description: <command-description>
# arguments: [{
#	name: <argument-name>
#	description: <argument-description>
#	possible-values: <possible-values>
#	default-value: <default-value>
# }]
func add_command(command: Dictionary) -> void:
	commands.append(command)


func _on_line_edit_text_submitted(new_text):
	output(run_command(new_text))
	edit.text = ''
	_on_line_edit_text_changed('')


func _on_line_edit_text_changed(new_text: String):
	# parse the text
	var bbcode := highlight_command(new_text)
	
	# give that text to the edit
	edit_display.clear()
	edit_display.append_text(bbcode)


func highlight_command(text: String) -> String:
	var bbcode := ''
	var words := text.split(" ")
	bbcode += "[color=#bde8a0]" + words[0] + "[/color] "
	
	words.remove_at(0)
	for word in words:
		var split = word.split('=') 
		if len(split) == 2:
			var parameter := split[0]
			var argument := split[1]
			bbcode += "[color=#e39fed]{0}[/color]=[color=#ede3a8]{1}[/color] ".format([parameter, argument])
		else:
			bbcode += word + ' '
	
	return bbcode


# terminates the program due to an error
func fatal_error(reason: String) -> void:
	# put error logs in the console
	output("[color=red]Game terminated due to fatal error:[/color]")
	output(reason)
	
	await get_tree().process_frame
	
	# save the console log to a file 
	var filename := 'user://crash_report.txt'
	var file: FileAccess = FileAccess.open(filename, FileAccess.WRITE)
	if FileAccess.get_open_error() == OK:
		file.store_string("""
--------------------------------------------------------------------------------------------------------------------------------------------------------------
Teleorb has encountered a fatal error. Please create an issue at https://github.com/FireSquid6/teleorb/issues or email jdeiss06@gmail.com with this error log.
--------------------------------------------------------------------------------------------------------------------------------------------------------------

Note: the following is in BBCode. Parse it with something like http://patorjk.com/bbcode-previewer/.
[wave amp=50 freq=2][rainbow freq=0.2 sat=10 val=20]I'm going to kill myself :D[/rainbow][/wave]""")
		file.store_string(console_text)
		file = null
		
		OS.shell_open(ProjectSettings.globalize_path(filename))
		
		# exit the game
		get_tree().quit()
