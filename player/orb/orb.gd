extends Node2D
class_name Orb

@export var _follower: CharacterBody2D
@export var _timer: Timer
@export var _wall_detector: Area2D
@export var _orb: Area2D

signal hit(pos: Vector2)
signal destroyed(pos: Vector2)

var velocity: Vector2 = Vector2(0, 0)
var speed: float = 0

func _ready():
	_timer.connect("timeout", _on_timeout)

func throw(pos: Vector2, direction: Vector2, spd: float, lifespan: float):
	Log.out(str(direction))
	speed = spd
	position = pos
	
	velocity = direction * speed
	_timer.wait_time = lifespan


func _physics_process(delta) -> void:
	_orb.position += velocity * delta
	
	if _area_overlaps(_wall_detector):
		_follower.velocity = (_orb.position - _follower.position) / delta
		_follower.move_and_slide()
	else:
		_follower.position = _orb.position


func _on_timeout():
	destroy()


func destroy():
	emit_signal("destroyed", position + _orb.position + _follower.position)
	kill()

# physics processs:
# - move self
# - move and slide follower
# - check if collided

func _touched_something() -> void:
	emit_signal("hit", _follower.global_position)
	kill()

func _area_overlaps(area: Area2D) -> bool:
	return area.get_overlapping_areas().size() > 0 or area.get_overlapping_bodies().size() > 0

func kill():
	queue_free()


func _on_orb_area_entered(_area) -> void:
	_touched_something()


func _on_orb_body_entered(_body) -> void:
	_touched_something()
