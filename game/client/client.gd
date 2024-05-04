extends Node

var peer = null
signal connected

func connect_to_server(ip: String):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, 5000)
	Log.out("Connecting to " + ip)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		Log.out("Disconnected")
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connect)
	
	World.main.join_game()


func _on_connect():
	Log.out("connected to server")
	emit_signal("connected")
