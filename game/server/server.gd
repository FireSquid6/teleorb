extends Node


const PORT = 3412
const MAX_CLIENTS = 24  # subject to change
const ENV_VARIABLE = "TELEORB_SERVER_JSON_PATH"

var peer = null
var isDedicatedServer = false
var serverConfig: Dictionary = {}
var running = false


func _init() -> void:
	var path = _get_json_filepath()
	Log.out("Server singleton initialized")
	if FileAccess.file_exists(path):
		Log.out("Found path for dedicated server json: " + path)
		var string = FileAccess.get_file_as_string(path)
		var serverJson = JSON.parse_string(string)
		
		isDedicatedServer = serverJson["enabled"]
		serverConfig = serverJson
	else:
		Log.out("No dedicated server json path found")

func _ready() -> void:
	if isDedicatedServer and OS.has_feature("dedicated_server"):
		Log.out("Detected a dedicated server environment. Automatically starting the server.")
	multiplayer.allow_object_decoding = true


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
