extends Node2D
class_name Level


@onready var camera: Camera2D = get_node("Camera")
@onready var player: Player = get_node("Player")
@onready var world: World = get_node("World")
@onready var hud: HUD = get_node("HUD")
@onready var canvas_modulate: CanvasModulate = $CanvasModulate


signal level_references_initialized(level: Level)
signal level_loaded(level: Level)
signal room_restarted()
signal room_changed(new_room: Rect2)


func _enter_tree():
	# TODO: add level load time print
	Console.output("[u][color=green]Loading level. . .[/color] \"[color=aqua]{0}[/color]\"[/u]\n".format([name]))

func _ready():
	emit_signal("level_references_initialized", self)
	
	canvas_modulate.visible = !world.skip_lighting
	
	Console.output("\n[u][color=green]Level loaded successfully![/color]")
	emit_signal("level_loaded", self)


func goto_level(scene: PackedScene):
	Console.output("Exiting level {0} and heading to level {1} ")


func restart_room():
	emit_signal("room_restarted")


func _input(event: InputEvent):
	Console.output(event.as_text())
