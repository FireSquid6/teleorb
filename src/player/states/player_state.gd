extends State
class_name PlayerState


@onready var player: Player = get_node('../..')
var walljump_buffer: Area2D


func _ready():
	await player.ready
	walljump_buffer = player.get_node("WalljumpBuffer")

func request_walljump():
	var jump_pressed: bool = player.input["jump_pressed"]
	var move: int = player.input["move"]
	
	# process the walljump buffer
	if len(walljump_buffer.get_overlapping_bodies()) and jump_pressed and player.state_machine.selected_state.name == "StateFalling":
		player.walljump_buffered = true
	
	# check if a walljump should be executed
	if player.is_on_wall() and (jump_pressed or player.walljump_buffered) and move != 0 and player.walljumps_left > 0:
		player.velocity.x = player.walljump_spd * -move
		player.walljump_buffered = false
		player.walljumps_left -= 1
		player.cancel_dir(move)
		machine.change_state("StateJumping")
