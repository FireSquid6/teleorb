extends Node
class_name Main

@export var ui_canvas: CanvasLayer
@export var level_container: Node

var level_scene = preload("res://level/level.tscn")

func _ready() -> void:
	World.main = self
	set_ui(preload("res://ui/title_screen/title_screen.tscn").instantiate())


func start_game(level: String):
	if not multiplayer.is_server():
		Log.fatal("tried to start game as a client")
	
	Log.out("Starting the game...")
	get_tree().paused = false
	
	_start_level.call_deferred(level)
	
	if Server.is_dedicated_server:
		set_ui(preload("res://ui/dedicated_server/dedicated-server.tscn").instantiate())
	else:
		set_ui(preload("res://ui/hud/hud.tscn").instantiate())


func join_game(level: String):
	get_tree().paused = false
	set_ui(preload("res://ui/hud/hud.tscn").instantiate())
	Log.out("Joining the game...")
	
	_join_level.call_deferred(level)


func set_ui(node: Node):
	for c in ui_canvas.get_children():
		ui_canvas.remove_child(c)
		c.queue_free()
	ui_canvas.add_child(node)

func _start_level(level_string: String):
	var level: Level = level_scene.instantiate()
	level_container.add_child(level)
	level.start.call_deferred(level_string)


func _join_level(level_string: String):
	var level: Level = level_scene.instantiate()
	level_container.add_child(level)
	level.spawn.call_deferred(level_string)


func _clear_level():
	for c in level_container.get_children():
		level_container.remove_child(c)
		c.queue_free()

func stop_game():
	for c in level_container.get_children():
		level_container.remove_child(c)
		c.queue_free()
