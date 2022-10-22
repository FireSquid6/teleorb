extends State
class_name PlayerState


@onready var player: Player = get_node('../..')
var walljump_buffer: Area2D


func _ready():
	await player.ready
	walljump_buffer = player.get_node("WalljumpBuffer")
