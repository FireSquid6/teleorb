extends Node
class_name Main

@export var ui_canvas: CanvasLayer
@export var level_container: Node

func _ready() -> void:
	World.main = self
	set_ui(preload("res://ui/title_screen/title_screen.tscn").instantiate())
	if Server.is_dedicated_server and OS.has_feature("dedicated_server"):
		start_game()


func start_game():
	Log.out("Starting the game...")
	get_tree().paused = false
	
	if multiplayer.is_server():
		change_level.call_deferred(load("res://level/level.tscn"))
	
	if Server.is_dedicated_server:
		set_ui(preload("res://ui/dedicated_server/dedicated-server.tscn").instantiate())
	else:
		set_ui(preload("res://ui/hud/hud.tscn").instantiate())
	
	Log.out("Game started.")

# TODO: Add all levels to the LevelSpawner node

func set_ui(node: Node):
	for c in ui_canvas.get_children():
		ui_canvas.remove_child(c)
		c.queue_free()
	ui_canvas.add_child(node)

func change_level(scene: PackedScene):
	for c in level_container.get_children():
		level_container.remove_child(c)
		c.queue_free()
	level_container.add_child(scene.instantiate())
