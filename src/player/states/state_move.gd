extends PlayerState


func _logic(delta: float = -1.0):
	var input = player.input
	
	# accelerate based on the player's movements
	player.run(input['move'], true)
