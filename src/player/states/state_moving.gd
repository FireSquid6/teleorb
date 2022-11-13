extends PlayerState
# state when the player is moving on the ground


func _enter(_args := []) -> void:
	# restore walljumps
	player.walljumps_left = player.max_walljumps
	
	# if there is a jump buffered, jump
	if player.jump_buffered:
		machine.change_state("StateJumping")
	
	# allow the player to throw the orb again
	player.can_throw = true


func _logic(delta: float = -1.0) -> void:
	var input = player.input
	
	# accelerate based on the player's movements
	player.run(delta, input['move'], true)
	
	# check if the player should jump
	if input["jump_pressed"]:
		machine.change_state("StateJumping")
	
	# check if the player has walked off a ledge
	if !player.is_on_floor():
		machine.change_state("StateFalling")
