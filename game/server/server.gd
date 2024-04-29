extends Node


const PORT = 5000
const MAX_CLIENTS = 24  # subject to change
const ENV_VARIABLE = "TELEORB_SERVER_JSON_PATH"

var peer = null
var is_dedicated_server = false
var running = false
var http_server: HttpServer
var vars: ServerVars

func _ready() -> void:
	vars = ServerVars.new()
	
	
	
	if is_dedicated_server and OS.has_feature("dedicated_server"):
		Log.out("Detected a dedicated server environment. Automatically starting the server.")
		start_server()


func start_server():
	Log.out("\nStarting server...")
	
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	Log.out(str(IP.get_local_addresses()))
	running = true


func peer_connected(id: int):
	Log.out("Player connected: " + str(id))


func peer_disconnected(id: int):
	Log.out("Player disconnected: " + str(id))


func validate_secret(secret: String):
	return secret == vars.get_value("server_scret")
