extends Node

var peer = null

func connect_to_server(ip: String):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, 3412)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connect)


func _on_connect():
	print("connected to server")
