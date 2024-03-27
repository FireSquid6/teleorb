extends Node
class_name Main

@onready var ui: Control = $UI
@onready var level_container: Node = $Level

func start_game():
	ui.hide()
	get_tree().paused = false
	
	if multiplayer.is_server():
		change_level.call_deferred(load("res://level/level.tscn"))


func change_level(scene: PackedScene):
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	level.add_child(scene.instantiate())
