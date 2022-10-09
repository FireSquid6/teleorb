extends Node2D
class_name World


@onready var shape_containers: Node2D = $Areas
@onready var level: Level = get_parent()
var player: Player
var camera_shapes: Array[Rect2] = []  # an array of shape 2D's used to define different rooms for the camera


func _ready():
	await level.ready
	player = level.player
	
	for collision_shape in shape_containers.get_children():
		camera_shapes.append(collision_shape_2d_to_rect2(collision_shape))
	
	shape_containers.queue_free()


func collision_shape_2d_to_rect2(collision_shape: CollisionShape2D) -> Rect2:
	var left_corner: Vector2 = Vector2(-1, -1)
	var size: Vector2 = Vector2(-1, -1)
	if collision_shape.shape as RectangleShape2D:
		left_corner = collision_shape.position - (collision_shape.shape.size / 2)
		size = collision_shape.shape.size * 2
	return Rect2(left_corner, size)
