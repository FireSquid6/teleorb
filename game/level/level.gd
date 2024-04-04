extends Node2D
class_name Level


func _ready():
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	for id in multiplayer.get_peers():
		add_player(id)
	
	if not Server.isDedicatedServer:
		add_player(1)

@rpc("any_peer")
func add_orb(orb: Orb):
	print("on player throw orb")
	$Orbs.add_child(orb)

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(remove_player)


func add_player(id: int):
	var player: Player = preload("res://player/player.tscn").instantiate()
	# Set player id.
	player.name = str(id)
	$Players.add_child(player, true)
	


func remove_player(id: int):
	if not $Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()
