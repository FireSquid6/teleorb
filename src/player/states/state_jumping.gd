extends PlayerState


func _enter(_args := []) -> void:
	player.jump_buffered = false
	
	# set velocity to jump spd
	player.velocity.y = -player.jump_spd
	
	# start the timer
	var timer: Timer = player.get_node("Times/JumpTime")
	timer.wait_time = player.jump_time
	timer.start()


func _logic(delta: float = -1.0) -> void:
	var input = player.input
	
	# switch state if velocity is greater than 0
	if input or player.is_on_ceiling() or player.velocity.y >= 0:
		machine.change_state("StateFalling")
	
	# accelerate
	player.run(input["move"], false, 1 / player.air_resistance)
	
	# deal with walljump
	request_walljump()
	

func _on_JumpTime_timeout():
	machine.change_state("StateFalling")
