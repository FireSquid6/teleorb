extends PlayerState

@onready var cyote_time = 0

func _enter(_args := []) -> void:
	cyote_time = 0
	if machine.state_history[0] == "StateMoving":
		cyote_time = player.cyote_time


func _logic(delta: float = -1.0):
	var input = player.input
	
	# move
	player.run(delta, input["move"], false, 1 / player.air_resistance)
	
	# go back to moving if on floor
	if player.is_on_floor():
		machine.change_state("StateMoving")
	
	# deal with cyote time
	cyote_time = clamp(cyote_time - delta, 0, 99)
	if cyote_time > 0 and input["jump_pressed"]:
		machine.change_state("StateJumping")
	
	# fall
	player.velocity.y += player.grv * delta
	if player.velocity.y > player.terminal_velocity:
		player.velocity.y = player.terminal_velocity
	
	# buffer jump
	var overlapping = player.jump_buffer_area.get_overlapping_bodies()
	if len(overlapping) > 0 and input["jump_pressed"]:
		player.jump_buffered = true
	
	# deal with walljump
	request_walljump()
