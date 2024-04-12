extends Resource
class_name Segment

enum BIOMES {
	CAVE
}

static var transitions: Dictionary = {
	BIOMES.CAVE: preload("res://components/transitions/cave_transition.tscn")
}

@export var biome: BIOMES
@export var scene: PackedScene
@export var name: String
