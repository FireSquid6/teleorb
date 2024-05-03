extends Node
class_name Main

@export var ui_canvas: CanvasLayer
@export var level_container: Node

var level_scene = preload("res://level/level.tscn")

func _ready() -> void:
	World.main = self
	set_ui(preload("res://ui/title_screen/title_screen.tscn").instantiate())


func start_game(level: String):
	Log.out("Starting the game...")
	get_tree().paused = false
	
	if multiplayer.is_server():
		_reset_level.call_deferred(level)
	
	if Server.is_dedicated_server:
		set_ui(preload("res://ui/dedicated_server/dedicated-server.tscn").instantiate())
	else:
		join_game()


func join_game():
	get_tree().paused = false
	set_ui(preload("res://ui/hud/hud.tscn").instantiate())
	Log.out("Game joined.")


func set_ui(node: Node):
	for c in ui_canvas.get_children():
		ui_canvas.remove_child(c)
		c.queue_free()
	ui_canvas.add_child(node)

func _reset_level(level_string: String):
	for c in level_container.get_children():
		level_container.remove_child(c)
		c.queue_free()
	var level: Level = level_scene.instantiate()
	level_container.add_child(level)
	level.start.call_deferred(level_string)


func stop_game():
	for c in level_container.get_children():
		level_container.remove_child(c)
		c.queue_free()
