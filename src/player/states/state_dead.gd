extends PlayerState
# state while the player's death animation is playing


@onready var _timer = $ResetTimer


func _enter(args := []):
	player.velocity = Vector2.ZERO
	_timer.start


func _on_animated_sprite_2d_animation_finished():
	if player.sprite.animation == "die":
		player.level.restart_room() 
