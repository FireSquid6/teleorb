extends Node2D


func _ready():
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	for id in multiplayer.get_peers():
		add_player(id)
	
	if not Server.isDedicatedServer:
		add_player(1)

func _on_player_throw_orb(orb: Orb):
	print("on player throw orb")
	$Orbs.add_child(orb)

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(remove_player)


func add_player(id: int):
	var character: Player = preload("res://player/player.tscn").instantiate()
	# Set player id.
	character.name = str(id)
	print("connecting signal")
	$Players.add_child(character, true)
	character.connect("spawn_orb", _on_player_throw_orb)


func remove_player(id: int):
	if not $Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()
