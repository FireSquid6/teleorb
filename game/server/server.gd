extends Node


var peer = null
const PORT = 3412
const MAX_CLIENTS = 24  # subject to change

func start_server():
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(peer_connected)
	print(IP.get_local_addresses())


@rpc("any_peer")
func do_output():
	print("Hey! I'm some output")


func peer_connected(id: int):
	print("Player connected " + str(id))
