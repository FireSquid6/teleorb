extends Node
class_name Main

@export var menu: Node
@export var world: Node

func start_game():
	menu.queue_free()
	get_tree().paused = false
	
	if multiplayer.is_server():
		change_level.call_deferred(load("res://level/level.tscn"))


func change_level(scene: PackedScene):
	for c in world.get_children():
		world.remove_child(c)
		c.queue_free()
	world.add_child(scene.instantiate())
