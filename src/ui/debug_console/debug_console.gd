extends CanvasLayer


@export var key = KEY_F12
signal unfocused()
signal focused()

@onready var body: RichTextLabel = $DebugConsole/Panel/VBoxContainer/RichTextLabel
@onready var edit: LineEdit = $DebugConsole/Panel/VBoxContainer/LineEdit


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	event = event as InputEventKey
	if event:
		if event.physical_keycode == key and event.pressed:
			visible = !visible


# prints both to the stdout and the rich text label
# it's recommended you do Console.output() instead of print() or print_rich()
func output(text: String, use_bbcode: bool = true) -> void:
	if use_bbcode:
		print_rich(text)
	else:
		print(text)
	
	body.append_text("\n"+text)


func _on_line_edit_focus_entered():
	emit_signal("focused")


func _on_line_edit_text_submitted(new_text):
	emit_signal("unfocused")
