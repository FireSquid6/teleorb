extends Node

var peer = null

const IP_ADDRESS = "192.168.1.14"

func connect_to_server():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, 3412)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connect)


func _on_connect():
	print("connected to server")
	Server.rpc("do_output")
