extends Node
class_name Orb


var velocity: Vector2 = Vector2.ZERO
@onready var area: Area2D = $OrbArea
@onready var mask: CharacterBody2D = $PlayerMask


signal hit(mask_pos: Vector2)


func _physics_process(delta):
	# move the area
	area.position += velocity * delta
	
	# move the mask
	var mask_distance := Vector2(mask.position.distance_to(area.position), 0).rotated(mask.position.angle_to(area.position))
	mask.move_and_collide(mask_distance)


# when the orb hits a wall, emit a signal to teleport the player
func _on_orb_area_body_entered(_body):
	emit_signal("hit", mask.position)
