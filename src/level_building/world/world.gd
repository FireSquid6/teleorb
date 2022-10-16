extends Node2D
class_name World


@onready var shape_containers: Node2D = $Areas
@onready var level: Level = get_parent()
@onready var camera: Camera2D = $"../Player/Camera"
var player: Player
var camera_shapes: Array[Rect2] = []  # an array of shape 2D's used to define different rooms for the camera
var light_textures: Array[Texture] = []  # an array of textures for lighting
var active_rectangle: Rect2 = Rect2(0, 0, 0, 0)

var camera_area_output_string = "CollisionShape2D of [color=green](position = {0}, size = {1})[/color] converted to Rect2 of [color=green](position = {2}, end = {3})[/color]"

func _ready():
	await level.level_references_initialized
	player = level.player
	
	# load the camera areas
	Console.output('[color=green]Parsing Camera Areas:[/color]')
	
	for collision_shape in shape_containers.get_children():
		collision_shape = collision_shape as CollisionShape2D
		var rect2: Rect2 = collision_shape_2d_to_rect2(collision_shape)
		camera_shapes.append(rect2)
		
		Console.output(camera_area_output_string.format([collision_shape.position, collision_shape.shape.size, rect2.position, rect2.end]))
	
	Console.output('')
	
	# TODO: generate light textures from the camera areas
	Console.output('[color=green]Generating light textures:[/color]')
	Console.output('[color=red]Feature not implemented yet[/color]')
	Console.output('')
	
	shape_containers.queue_free()


func _process(delta):
	
	if !active_rectangle.has_point(player.position):
		for rect in camera_shapes:
			rect = rect as Rect2
			
			if rect.has_point(player.position):
				active_rectangle = rect
				
				camera.limit_left = rect.position.x
				camera.limit_top = rect.position.y
				camera.limit_bottom = rect.end.y
				camera.limit_right = rect.end.x
				
				break


func collision_shape_2d_to_rect2(collision_shape: CollisionShape2D) -> Rect2:
	var pos: Vector2 = Vector2(-1, -1)
	var end: Vector2 = Vector2(-1, -1)
	if collision_shape.shape as RectangleShape2D:
		var half_size = collision_shape.shape.size * 0.5
		
		pos.x = (collision_shape.position - half_size).x
		pos.y = (collision_shape.position - half_size).y
		end.x = (collision_shape.position + half_size).x
		end.y = (collision_shape.position + half_size).y
	return Rect2(pos, end - pos)
