extends Area2D
class_name Orb

@export var _follower: CharacterBody2D
@export var _timer: Timer

signal hit(pos: Vector2)
signal destroyed(pos: Vector2)

var velocity: Vector2 = Vector2(0, 0)

func _ready():
	_timer.connect("timeout", _on_timeout)

func throw(direction: Vector2, speed: float, lifespan: float):
	velocity = direction * speed
	_timer.wait_time = lifespan


func _physics_process(delta) -> void:
	# old code copied from when I was 16
	# might have issues. I have no idea how I got there.
	position += velocity * delta
	
	_follower.velocity = (position - _follower.position) / delta
	_follower.move_and_slide()


func _on_timeout():
	emit_signal("destroyed", _follower.position)
	

# physics processs:
# - move self
# - move and slide follower
# - check if collided

func _touched_something(node: CollisionObject2D) -> void:
	if node.get_collision_layer_value(5):
		emit_signal("destroyed", _follower.position)
		kill()
	elif node.get_collision_layer_value(1):
		emit_signal("hit", _follower.position)
		kill()


func kill():
	queue_free()


func _on_body_entered(body: CollisionObject2D) -> void:
	_touched_something(body)


func _on_area_entered(area: CollisionObject2D) -> void:
	_touched_something(area)
