extends PlayerState


# TODO: Play an animation instead of just an instant teleport
func _enter(args := [-1]):
	# make sure that the argument was given properly
	if args[0] is Vector2:
		# move to the position
		player.position = args[0]
		
		# go to falling
		machine.change_state("StateFalling")
		
	else:
		# go back to falling. Something went wrong
		push_error("Oopsie! Something went wrong and StateTeleport was transitioned to without a positional argument. You are a moron.")
		machine.change_state("StateFalling")
