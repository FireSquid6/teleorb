class_name PlayerState
extends State
# parent class for all player states


var _walljump_buffer: Area2D
@onready var player: Player = get_node('../..')



func _ready():
	await player.ready
	_walljump_buffer = player.get_node("WalljumpBuffer")
