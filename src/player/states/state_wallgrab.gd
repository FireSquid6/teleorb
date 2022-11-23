extends PlayerState
# state for when the player is grabbing the wall

var slipping = false
@onready var _grab_timer: Timer = $GrabTimer
@onready var _move_dir: int


func _enter(args := []):
	player.velocity = Vector2.ZERO
	slipping = false
	_grab_timer.start()
	
	for i in player.get_slide_collision_count():
		var slide: KinematicCollision2D = player.get_slide_collision(i)
		if abs(slide.get_normal().x) == 1:
			_move_dir = -slide.get_normal().x
			break


func _logic(delta := 0.0):
	var input := player.input
	
	if slipping:
		player.velocity.y += player.grab_grb * delta
	
	# walljump
	if (input["jump_pressed"] or player.walljump_buffered) and player.walljumps_left > 0:
		player.walljumps_left -= 1
		player.walljump_buffered = false
		player.velocity.x = player.walljump_spd * -_move_dir
		
		player.cancel_dir(_move_dir)
		
		machine.change_state("StateJumping")
		
	
	# stop grabbing if grab released
	if !input["wallgrab"]:
		machine.change_state("StateFalling")
	
	# go back if the player is on wall
	if player.is_on_floor():
		machine.change_state("StateMoving")


func _can_transition() -> bool:
	return (player.is_on_wall() and !player.is_on_floor())


func _on_grab_timer_timeout():
	slipping = true
