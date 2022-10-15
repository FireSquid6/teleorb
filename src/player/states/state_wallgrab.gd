extends PlayerState


var slipping = false
@onready var grab_timer: Timer = $GrabTimer

func _enter(args := []):
	player.velocity = Vector2.ZERO
	slipping = false
	grab_timer.start()


func _logic(delta := 0.0):
	var input := player.input
	
	if slipping:
		player.velocity.y += player.grab_grb * delta
	
	# deal with walljump
	request_walljump()
	
	# stop grabbing if grab released
	if !input["wallgrab"]:
		machine.change_state("StateFalling")


func _can_transition() -> bool:
	return (player.is_on_wall() and !player.is_on_floor())


func _on_grab_timer_timeout():
	slipping = true
