class_name Orb
extends Node
# node that represents the orb the player throws


signal hit(mask_pos: Vector2)  # fires when the orb hits a wall

var velocity: Vector2 = Vector2.ZERO

@onready var _area: Area2D = $OrbArea
@onready var _mask: CharacterBody2D = $PlayerMask
@onready var _player = get_parent()


func _ready() -> void:
	_mask.position = _player.position + (velocity.normalized() * 2)
	_area.position = _player.position + (velocity.normalized() * 2)


func _physics_process(delta) -> void:
	# move the area
	_area.position += velocity * delta
	
	# move the mask
	_mask.velocity = (_area.position - _mask.position) / delta
	_mask.move_and_slide()


# when the orb hits a wall, emit a signal to teleport the player
func _on_orb_area_body_entered(_body) -> void:
	emit_signal("hit", _mask.position)
	_player.orb_thrown = false
	queue_free()
