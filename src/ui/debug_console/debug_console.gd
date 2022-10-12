extends CanvasLayer


@export var key = KEY_F12
signal unfocused()
signal focused()

@onready var body: RichTextLabel = $DebugConsole/Panel/VBoxContainer/Body
@onready var edit: LineEdit = $DebugConsole/LineEdit
@onready var edit_display: RichTextLabel = $DebugConsole/Panel/VBoxContainer/Edit
var pre_body = ''


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	body.clear()
	body.append_text(pre_body)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
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
	if use_bbcode:
		print_rich(text)
	else:
		print(text)
	
	if body:
		body.append_text("\n"+text)
	else:
		pre_body += "\n"+text


func run_command(text) -> String:
	return '[color=red]Syntax Error. Command [color=white]"' + highlight_command(text) + '"[/color] not recognized.[/color]'


func add_command(callable: Callable, data: CommandData) -> bool:
	return false


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


class CommandData:
	pass
