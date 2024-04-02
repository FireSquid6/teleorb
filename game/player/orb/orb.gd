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


func _on_timeout():
	emit_signal("destroyed", _follower.position)
	

# physics processs:
# - move self
# - move and slide follower
# - check if collided
