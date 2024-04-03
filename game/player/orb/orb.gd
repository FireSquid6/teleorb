extends Area2D
class_name Orb

@export var _follower: CharacterBody2D
@export var _timer: Timer
@export var _wall_detector: Area2D

signal hit(pos: Vector2)
signal destroyed(pos: Vector2)

var velocity: Vector2 = Vector2(0, 0)
var speed: float = 0

func _ready():
	_timer.connect("timeout", _on_timeout)

func throw(pos: Vector2, direction: Vector2, spd: float, lifespan: float):
	speed = spd
	position = pos
	
	velocity = direction * speed
	print(velocity)
	_timer.wait_time = lifespan


func _physics_process(delta) -> void:
	position += velocity * delta
	
	_follower.velocity = (position - _follower.position).normalized() * speed * delta
	_follower.move_and_slide()


func _on_timeout():
	destroy()


func destroy():
	emit_signal("destroyed", _follower.position)
	kill()

# physics processs:
# - move self
# - move and slide follower
# - check if collided

func _touched_something(node) -> void:
	print("touched something")
	emit_signal("hit", _follower.position)
	kill()

func _area_overlaps(area: Area2D) -> bool:
	return area.get_overlapping_areas().size() > 0 or area.get_overlapping_bodies().size() > 0

func kill():
	queue_free()

func _on_body_entered(body) -> void:
	_touched_something(body)


func _on_area_entered(area) -> void:
	_touched_something(area)
