extends Node2D
class_name Level

@export var entities: Node2D
@export var _orb_scene: PackedScene
@export var _player_scene: PackedScene

func _ready():
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_remove_player)
	
	for id in multiplayer.get_peers():
		_add_player(id)
	
	if not Server.isDedicatedServer:
		_add_player(1)


@rpc("any_peer", "call_local", "reliable")
func _add_orb(pos: Vector2, direction: Vector2, orb_speed: float, orb_lifespan: float, id: String):
	Log.out("running add orb function on: " + str(multiplayer.get_unique_id()))
	var orb = _orb_scene.instantiate()
	
	orb.throw(pos, Vector2(-1, 0), orb_speed, orb_lifespan)
	entities.add_child(orb, true)
	orb.name = id

func add_orb(creator: Player, direction: Vector2, id: String):
	var stats = creator.get_stats()
	_add_orb.rpc(creator.position, direction, stats.orb_speed, stats.orb_lifespan, id)


func find_entity_by_name(id: String) -> Node:
	var entities: Array[Node] = entities.get_children()
	
	for entity in entities:
		if entity.name == id:
			return entity
	
	return null

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(_add_player)
	multiplayer.peer_disconnected.disconnect(_remove_player)


func _add_player(id: int):
	var player: Player = _player_scene.instantiate()
	# Set player id.
	player.name = str(id)
	entities.add_child(player, true)
	


func _remove_player(id: int):
	if not entities.has_node(str(id)):
		return
	entities.get_node(str(id)).queue_free()
