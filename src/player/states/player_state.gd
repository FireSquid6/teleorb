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
	if player.is_on_wall() and (jump_pressed or player.walljump_buffered) and move != 0 and player.walljumps_left > 0:
		player.velocity.x = player.walljump_spd * -move
		player.walljump_buffered = false
		player.walljumps_left -= 1
		player.cancel_dir(move)
