extends Node2D
class_name Level


@onready var camera: Camera2D = get_node("Camera")
@onready var player: Player = get_node("Player")
@onready var world: World = get_node("World")
@onready var hud: HUD = get_node("HUD")
@onready var cursor: Node2D = get_node("Cursor")


signal level_references_initialized(level: Level)
signal level_loaded(level: Level)


func _enter_tree():
	# TODO: add level load time print
	print_rich("
[b]-----------------------------------------------------------------------------------[/b]
[b][u][color=green]Loading level. . .[/color] \"[color=aqua]{0}[/color]\"[/u][/b]\n".format([name]))

func _ready():
	emit_signal("level_references_initialized", self)
	print_rich("[b][u][color=green]Level loaded successfully in [color=aqua]{1}[/color]ms[/color][/u][/b]
[b]-----------------------------------------------------------------------------------[/b]".format([name, "x"]))
	emit_signal("level_loaded", self)


func goto_level(scene: PackedScene):
	print_rich("[b]-----------------------------------------------------------------------------------[/b]
[b]Exiting level {0} and heading to level {1}
[b]-----------------------------------------------------------------------------------[/b]
	")
