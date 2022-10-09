extends Node2D
class_name Level


@onready var camera: Camera2D = get_node("Camera")
@onready var player: Player = get_node("Player")
@onready var world: World = get_node("World")
@onready var hud: HUD = get_node("HUD")
@onready var cursor: Node2D = get_node("Cursor")


signal level_loaded()  # emitted on this object's ready function


func _enter_tree():
	print_rich("[u][color=yellow]Loading Level[/color] \"[color=aqua]{0}[/color]\"[/u]".format([name]))

func _ready():
	print_rich("[u][color=yellow]Started Level[/color] \"[color=aqua]{0}[/color]\"[/u]".format([name]))
	emit_signal("level_loaded", self)
