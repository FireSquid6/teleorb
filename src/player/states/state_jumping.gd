extends PlayerState


func _enter(_args := []) -> void:
	player.jump_buffered = false
	
	# set velocity to jump spd
	player.velocity.y = player.jump_spd


func _logic(delta: float = -1.0) -> void:
	var input = player.input
	
	# switch state if velocity is greater than or equal to 0
	if !input["jump"] or player.velocity.y >= 0 or player.is_on_ceiling():
		machine.change_state("StateFalling")
	
	# accelerate
	player.run(delta, input["move"], false, 1 - player.air_resistance)
	
	# change velocity
	player.velocity.y += player.jump_grv * delta
