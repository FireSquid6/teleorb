extends PlayerState


func _enter(_args := []) -> void:
	# restore walljumps
	player.walljumps_left = player.max_walljumps


func _logic(delta: float = -1.0):
	var input = player.input
	
	# accelerate based on the player's movements
	player.run(input['move'], true)
	
	# check if the player should jump
	if input["jump_pressed"]:
		machine.change_state("StateJumping")
	
	# check if the player has walked off a ledge
	if !player.is_on_floor():
		machine.change_state("StateFalling")
