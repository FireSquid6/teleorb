extends Node

var peer = null

func connect_to_server(ip: String):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, 3412)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connect)


func _on_connect():
	print("connected to server")
	Server.rpc("do_output")
