extends Node2D
class_name Level

@export var entities: Node2D
@export var _orb_scene: PackedScene
@export var _player_scene: PackedScene
@export var segments: Array[Segment]
@export var startpoint: Node2D
var level_id: String = ""

func start(level: String):
	level_id = level
	World.curret_level = self
	if not multiplayer.is_server():
		Log.fatal("tried to create level while not the server")
		return
	
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_remove_player)
	
	for id in multiplayer.get_peers():
		_add_player(id)
	
	if not Server.is_dedicated_server:
		_add_player(1)
	
	print(level)
	var course = Course.new(level)
	course.spawn_in(self, startpoint.position)


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
	entities.add_child(player, true)
	


func _remove_player(id: int):
	if not entities.has_node(str(id)):
		return
	entities.get_node(str(id)).queue_free()


class Course:
	var sections: Array[Section]
	
	func _init(level_string: String):
		validate_level_string(level_string)
		var section_codes := level_string.split("|")
		
		for section_code in section_codes:
			var segment_codes := section_code.split("-")
			var segments: Array[Segment] = []
			
			for segment_code in segment_codes:
				# TODO: error handling here
				var segment: Segment = load("res://segments/" + segment_code + ".tres")
				segments.append(segment)
			
			# todo: validate that all biomes are the same
			var biome = segments[0].biome
			var section = Section.new(biome, segments)
			sections.append(section)
	
	func spawn_in(level: Level, start_position: Vector2):
		var current_position = start_position
		for section in sections:
			current_position = section.spawn_in(level, current_position)
			# TODO: actually take biomes into account
			current_position = level.add_transition_segment([Segment.BIOMES.CAVE, Segment.BIOMES.CAVE], current_position)
	
	static func validate_level_string(level: String) -> void:
		var sections = level.split("|")
		if len(sections) != 4:
			Log.fatal("tried to spawn level with more or less than 4 sections: " + level)
		
		for section in sections:
			var segments = section.split("-")
			if len(segments) != 4:
				Log.fatal("tried to spawn improper level: " + level)


class Section:
	var biome: Segment.BIOMES
	var segments: Array[Segment]
	
	func _init(b: Segment.BIOMES, s: Array[Segment]):
		biome = b
		segments = s
	
	func spawn_in(level: Level, start_position: Vector2) -> Vector2:
		var next_start := start_position
		
		var transition_scene: PackedScene = Segment.transitions[segments[0].biome]
		var nodes: Array[Node2D] = []
		
		for i in range(len(segments) * 2 - 1):
			if i % 2 == 0:
				var index = floor(i / 2)
				var segment: Segment = segments[index]
				nodes.append(segment.scene.instantiate())
			else:
				nodes.append(transition_scene.instantiate())
		
		for node in nodes:
			next_start = level.add_segment(node, next_start)
		
		return next_start


func add_segment(node: Node, start: Vector2) -> Vector2:
	add_child(node)
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
	
	startpoint_node.queue_free()
	endpoint_node.queue_free()
	
	# spawn the segment and move it to the proper location
	var difference = startpoint_node.position
	node.position = start - difference
	return node.position + endpoint_node.position


func add_transition_segment(biomes: Array[Segment.BIOMES], start_position: Vector2) -> Vector2:
	return start_position
