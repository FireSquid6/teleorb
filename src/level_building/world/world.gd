extends Node2D
class_name World


@onready var shape_containers: Node2D = $Areas
@onready var level: Level = get_parent()
@onready var camera: Camera2D = $"../Player/Camera"
@onready var tilemap: TileMap = $Occluders
@onready var light_container: Node2D = $Lights
var player: Player
var camera_shapes: Array[Rect2] = []  # an array of shape 2D's used to define different rooms for the camera
var light_textures: Array[Texture] = []  # an array of textures for lighting
var active_rectangle: Rect2 = Rect2(0, 0, 0, 0)

var camera_area_output_string = "CollisionShape2D of [color=green](position = {0}, size = {1})[/color] converted to Rect2 of [color=green](position = {2}, end = {3})[/color]"

@export var ambient_light_color: Color = Color(0.4, 0.4, 0.4)
@export var ambient_light_energy: float = 1.25

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
	
	# generate light textures from the camera areas, and put a light there
	Console.output('[color=green]Generating light textures:[/color]')
	var image_index = 0
	for shape in camera_shapes:
		shape = shape as Rect2
		var image := create_light_texture(shape, tilemap)
		
		var light: PointLight2D = PointLight2D.new()
		
		light.texture= ImageTexture.create_from_image(image)
		
		image.save_png("user://image_{0}.png".format([image_index]))
		light.position = shape.position + (shape.size / 2)
		light.color = ambient_light_color
		light.energy = ambient_light_energy
		light.light_mask = 0
		
		light_container.add_child(light)
		
		Console.output("Light created at {0}.".format([light.position])) 
		image_index += 1
	Console.output('[color=green]Light textures successfully generated![/color]')
	
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


func create_light_texture(rect: Rect2, tilemap: TileMap, layer: int = 0, blend: float = 0.125) -> Image:
	var lightmap: Image = Image.new();
	lightmap.create(rect.size.x, rect.size.y, false, Image.FORMAT_RGB8);
	lightmap.fill(Color.BLACK)
	
	var tile_size: Vector2i = tilemap.tile_set.tile_size;
	var start_cell: Vector2i = Vector2i(rect.position) / tile_size;
	var cells: Vector2i = Vector2i(rect.size) / tile_size;
	var used_cells: Array[Vector2i] = tilemap.get_used_cells(layer)
	
	# iterates through the rows and columns of the tilemap
	for column in cells.x:
		for row in cells.y:
			var x_cell: int = start_cell.x + column
			var y_cell: int = start_cell.y + row
			
			var x: int = x_cell * tile_size.x
			var y: int = y_cell * tile_size.y
			
			if !(Vector2i(x_cell, y_cell) in used_cells):
				var pos: Vector2i = (Vector2i(x_cell, y_cell) - start_cell) * tile_size
				
				var fill_rect: Rect2 = Rect2(pos, tile_size)
				lightmap.fill_rect(fill_rect, Color.WHITE)
	
	
	return lightmap


func should_fill_pixel(image: Image, x: int, y: int) -> bool:
	var edges = [
		[x - 1, y],
		[x + 1, y],
		[x, y - 1],
		[x, y + 1],
		[x + 1, y + 1],
		[x - 1, y - 1],
		[x + 1, y - 1],
		[x - 1, y + 1,],
	]
	
	var white_neighbors = 0  # is it politcally correct to use this variable name?
	var image_width: int = image.get_width()
	var image_height: int = image.get_height()
	for edge in edges:
		var xx = edge[0]
		var yy = edge[1]
		
		if xx > 0 and xx < image_width and yy > 0 and yy < image_height:
			if image.get_pixel(xx, yy) == Color.WHITE:
				white_neighbors += 1
	
	return ((white_neighbors > 0) and (white_neighbors != 8))
