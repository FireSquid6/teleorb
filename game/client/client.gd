extends Node

var peer = null

func connect_to_server(ip: String):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, 5000)
	Log.out("Connecting to " + ip)
	
	multiplayer.multiplayer_peer = peer
	
	multiplayer.connected_to_server.connect(_on_connect)
	multiplayer.server_disconnected.connect(_on_disconnect)
	multiplayer.connection_failed.connect(_connection_failed)


@rpc("authority", "call_remote")
func set_level(level: String):
	Log.out("Recieved level from server: " + level)
	World.main.join_game(level)


func _on_connect():
	Log.out("connected to server")


func _on_disconnect():
	Log.out("disconnected from server")


func _connection_failed():
	Log.out("failed to connect to server")
