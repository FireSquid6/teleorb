extends PlayerState


@onready var timer = $ResetTimer


func _enter(args := []):
	player.velocity = Vector2.ZERO
	timer.start


func _on_animated_sprite_2d_animation_finished():
	if player.sprite.animation == "die":
		player.level.restart_room() 
