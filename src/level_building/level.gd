class_name Level
extends Node2D
# root node of every level

signal level_references_initialized(level: Level)  # fries at the start of this object's ready function
signal level_loaded(level: Level)  # fires at the end of this object's ready function
signal room_restarted()  # fires whenever the current room is retarted
signal room_changed(new_room: Rect2)  # fires whenever the player moves to another room

# these refs are meant to be accessed by other nodes
@onready var camera: Camera2D = get_node("Camera")
@onready var player: Player = get_node("Player")
@onready var world: World = get_node("World")
@onready var hud: HUD = get_node("HUD")
@onready var canvas_modulate: CanvasModulate = $CanvasModulate


func _ready():
	emit_signal("level_references_initialized", self)
	
	canvas_modulate.visible = !world.skip_lighting
	
	Console.output("\n[u][color=green]Level loaded successfully![/color]")
	emit_signal("level_loaded", self)


func _enter_tree():
	# TODO: add level load time print
	Console.output("[u][color=green]Loading level. . .[/color] \"[color=aqua]{0}[/color]\"[/u]\n".format([name]))


func goto_level(scene: PackedScene):
	Console.output("Exiting level {0} and heading to level {1} ")


func restart_room():
	emit_signal("room_restarted")
