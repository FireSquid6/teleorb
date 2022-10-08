extends PlayerState


# TODO: Play an animation instead of just an instant teleport
func _enter(args := [-1]):
	# make sure that the argument was given properly
	if args[0] is Vector2:
		# move to the position
		player.position = args[0]
		
		# if the previous state was StateMoving, move the player 1 pixel opposite to the current input direction
		# this is to prevent the player getting stuck in the wall
		# this is not a good solution, however it's all I got.
		if machine.state_history[1] == "StateMoving":
			player.position.x -= player.move
		
		# set the player's velocity
		player.velocity = Vector2.ZERO
		
		# go to falling
		machine.change_state("StateFalling")
		
	else:
		# go back to falling. Something went wrong
		push_error("Oopsie! Something went wrong and StateTeleport was transitioned to without a positional argument. You are a moron.")
		machine.change_state("StateFalling")
