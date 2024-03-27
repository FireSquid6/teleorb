extends Node


var peer = null
const PORT = 3412
const MAX_CLIENTS = 24  # subject to change

func start_server():
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	print(IP.get_local_addresses())


func peer_connected(id: int):
	print("Player connected " + str(id))


func peer_disconnected(id: int):
	print("Player disconnected " + str(id))
