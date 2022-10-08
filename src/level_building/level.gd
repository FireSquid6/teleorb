extends Node2D
class_name Level


@onready var camera: Camera2D = get_node("Camera")
@onready var player: Player = get_node("Player")
@onready var world: World = get_node("World")
@onready var hud: HUD = get_node("HUD")
@onready var cursor: Node2D = get_node("Cursor")


signal level_loaded()  # emitted on this object's ready function


func _ready():
	emit_signal("level_loaded", self)
