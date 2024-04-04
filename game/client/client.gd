extends Node

var peer = null
signal connected

func connect_to_server(ip: String):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, 3412)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to connect to server.")
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connect)


func _on_connect():
	Log.out("connected to server")
	emit_signal("connected")
