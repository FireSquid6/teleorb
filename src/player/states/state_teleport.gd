extends PlayerState


var played := false
var position := Vector2.ZERO


func _ready():
	await player.ready
	add_active_signal(player.sprite, "animation_finished", Callable(self, "_on_player_sprite_animation_finished"))
		


func _enter(args := [-1]):
	player.jump_buffered = false
	
	# make sure that the argument was given properly
	if args[0] is Vector2:
		# if the previous state was StateMoving, move the player 1 pixel opposite to the current input direction
		# this is to prevent the player getting stuck in the wall
		# this is not a good solution, however it's all I got.
		if machine.state_history[1] == "StateMoving":
			player.position.x -= player.move
		
		player.velocity = Vector2.ZERO
		
		position = args[0]
		
	else:
		# go back to falling. Something went wrong
		push_error("Oopsie! Something went wrong and StateTeleport was transitioned to without a positional argument. You are a moron.")
		machine.change_state("StateFalling")


func _on_player_sprite_animation_finished():
	if played:
		machine.change_state("StateFalling")
		played = false
		
		player.sprite.speed_scale = 1
	else:
		# reverse animation and move
		player.sprite.speed_scale = -1
		
		player.position = position
		AnimatedSprite2D
		player.sprite.frame = player.sprite.frames.get_frame_count("teleport") - 2
		played = true
