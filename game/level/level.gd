extends Node2D
class_name Level

@export var entities: Node2D
@export var _orb_scene: PackedScene
@export var _player_scene: PackedScene
@export var segments: Array[Segment]
@export var spawnpoint: Node2D

func _ready():
	World.curret_level = self
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_remove_player)
	
	for id in multiplayer.get_peers():
		_add_player(id)
	
	if not Server.is_dedicated_server:
		_add_player(1)
	
	var section = Section.new(Segment.BIOMES.CAVE, segments)
	section.spawn_in(self, $Startpoint.position)


@rpc("any_peer", "call_local", "reliable")
func _add_orb(pos: Vector2, direction: Vector2, orb_speed: float, orb_lifespan: float, id: String):
	Log.out("running add orb function on: " + str(multiplayer.get_unique_id()))
	var orb = _orb_scene.instantiate()
	
	orb.throw(pos, direction, orb_speed, orb_lifespan)
	entities.add_child(orb, true)
	orb.name = id

func add_orb(creator: Player, direction: Vector2, id: String):
	var stats = creator.get_stats()
	_add_orb.rpc(creator.position, direction, stats.orb_speed, stats.orb_lifespan, id)


func find_entity_by_name(id: String) -> Node:
	var nodes: Array[Node] = entities.get_children()
	
	for entity in nodes:
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
	player.position = spawnpoint.position
	entities.add_child(player, true)
	


func _remove_player(id: int):
	if not entities.has_node(str(id)):
		return
	entities.get_node(str(id)).queue_free()


class Section:
	var biome: Segment.BIOMES
	var segments: Array[Segment]
	
	
	func _init(b: Segment.BIOMES, s: Array[Segment]):
		biome = b
		segments = s
	
	func spawn_in(level: Level, start_position: Vector2):
		randomize()
		print(segments)
		segments.shuffle()
		var to_free: Array[Node] = []
		var next_start := start_position
		
		# we need to make sure all segments have the same biome
		for segment in segments:
			assert(segment.biome == biome) 
		
		var transition_scene: PackedScene = Segment.transitions[segments[0].biome]
		var nodes: Array[Node2D] = []
		
		for i in range(len(segments) * 2 - 1):
			if i % 2 == 0:
				var index = floor(i / 2)
				var segment: Segment = segments[index]
				print(index)
				print(segment.name)
				print(segment.scene)
				nodes.append(segment.scene.instantiate())
			else:
				nodes.append(transition_scene.instantiate())
		print(nodes)
		for node in nodes:
			level.add_child(node)
			var startpoint_node: Node2D = null
			var endpoint_node: Node2D = null
			
			for c in node.get_children():
				if c.name == "Startpoint":
					startpoint_node = c
				if c.name == "Endpoint":
					endpoint_node = c
			
			# if these are failing, a segment is improperly configured
			assert(endpoint_node != null)
			assert(startpoint_node != null)
			
			to_free.append(startpoint_node)
			to_free.append(endpoint_node)
			
			# spawn the segment and move it to the proper location
			var difference = startpoint_node.position
			node.position = next_start - difference
			print("new spawn")
			print(difference)
			print(next_start)
			print(node.position)
			next_start = node.position + endpoint_node.position
		
		for node in to_free:
			node.queue_free()







