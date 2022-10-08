extends Node
class_name Orb


var velocity: Vector2 = Vector2.ZERO
@onready var area: Area2D = $OrbArea
@onready var mask: CharacterBody2D = $PlayerMask
@onready var player = get_parent()


signal hit(mask_pos: Vector2)


func _ready():
	mask.position = player.position
	area.position = player.position


func _physics_process(delta):
	# move the area
	area.position += velocity * delta
	
	# move the mask
	mask.velocity = (area.position - mask.position) / delta
	mask.move_and_slide()


# when the orb hits a wall, emit a signal to teleport the player
func _on_orb_area_body_entered(_body):
	emit_signal("hit", mask.position)
	print("ORB")
	player.orb_thrown = false
	queue_free()
