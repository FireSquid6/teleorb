extends Node2D
class_name World


@onready var shape_containers: Node2D = $Areas
@onready var level: Level = get_parent()
var player: Player
var camera_shapes: Array[Rect2] = []  # an array of shape 2D's used to define different rooms for the camera
var light_textures: Array[Texture] = []  # an array of textures for lighting

var camera_area_output_string = "CollisionShape2D of [color=green](position = {0}, size = {1})[/color] converted to Rect2 of [color=green](position = {2}, size = {3})[/color]"

func _ready():
	await level.level_references_initialized
	player = level.player
	
	# load the camera areas
	Console.output('[b][color=green]Parsing Camera Areas:[/color][/b]')
	
	for collision_shape in shape_containers.get_children():
		collision_shape = collision_shape as CollisionShape2D
		var rect2: Rect2 = collision_shape_2d_to_rect2(collision_shape)
		camera_shapes.append(rect2)
		
		Console.output(camera_area_output_string.format([collision_shape.position, collision_shape.shape.size, rect2.position, rect2.size]))
	
	Console.output('')
	
	# TODO: generate light textures from the camera areas
	Console.output('[b][color=green]Generating light textures:[/color][/b]')
	Console.output('[color=red]Feature not implemented yet[/color]')
	Console.output('')
	
	shape_containers.queue_free()


func collision_shape_2d_to_rect2(collision_shape: CollisionShape2D) -> Rect2:
	var left_corner: Vector2 = Vector2(-1, -1)
	var size: Vector2 = Vector2(-1, -1)
	if collision_shape.shape as RectangleShape2D:
		left_corner = collision_shape.position - (collision_shape.shape.size / 2)
		size = collision_shape.shape.size * 2
	return Rect2(left_corner, size)
