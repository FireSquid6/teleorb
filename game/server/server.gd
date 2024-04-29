extends Node


const PORT = 5000
const MAX_CLIENTS = 24  # subject to change
const ENV_VARIABLE = "TELEORB_SERVER_JSON_PATH"

var peer = null
var is_dedicated_server = false
var server_config: Dictionary = {}
var running = false
var http_server: HttpServer

func _ready() -> void:
	var path = _get_json_filepath()
	if FileAccess.file_exists(path):
		Log.out("Found path for dedicated server json: " + path)
		var string = FileAccess.get_file_as_string(path)
		var serverJson = JSON.parse_string(string)
		
		is_dedicated_server = serverJson["enabled"]
		server_config = serverJson
	else:
		Log.out("No dedicated server json path found")
	
	
	if is_dedicated_server and OS.has_feature("dedicated_server"):
		Log.out("Detected a dedicated server environment. Automatically starting the server.")
		start_server()


func _get_json_filepath():
	if OS.has_environment(ENV_VARIABLE):
		return OS.get_environment(ENV_VARIABLE)
	else:
		var configPath = OS.get_config_dir()
		return configPath + "/teleorb-dedicated-server.json"


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
