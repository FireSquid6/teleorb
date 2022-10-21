extends Panel


# the url to report a bug at
const report_url = 'https://github.com/FireSquid6/teleorb/issues/new?assignees=FireSquid6&labels=bug&template=bug-report.md&title=%5BBUG%5D'
# a list of fun crash messages that can appear
var messages = [
	'Was this your goal?',
	'I bet no other game has a crash scene as cool as me.',
	'This is a feature. Trust me.',
	'huh',
	'That wasn\'t supposed to happen',
	'I\'m sorry. I failed you',
	'Jonathan Deiss probably wants to kill himself right now',
	'                I hope nobody notices that this message is off centered',
	'Try reading the console output and pretending it makes sense.',
]

@onready var body_text: String = Console.console_text
@onready var fun_label: Label = $VBoxContainer/Fun
@onready var console_body: RichTextLabel = $Panel/ConsoleBody


func _ready():
	console_body.append_text(body_text)
	
	messages.shuffle()
	fun_label.text = messages[0]


func _on_report_bug_pressed():
	OS.shell_open(report_url)


func _on_copy_button_pressed():
	OS.shell_open(ProjectSettings.globalize_path('user://crash_report.txt'))


func _on_close_game_pressed():
	get_tree().quit()
