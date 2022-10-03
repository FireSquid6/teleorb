extends CharacterBody2D
class_name Player


# whether the player has access to certain items
var has_dash: bool = false
var has_slide: bool = false
var has_orb: bool = false

var walljumps_left = 0  # the amount of walljumps the player has left

@export var move_spd: float = 500  # the speed the player moves at
@export var max_walljumps: int = 1  # the maximum amount of times the player can walljump

@onready var state_machine: StateMachine = get_node('StateMachine')
@onready var input: Dictionary = {}

func _physics_process(delta):
	# get input
	input = {
		"move" : int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left")),
		"dash" : Input.is_action_just_pressed("dash") and has_dash,
		"slide" : Input.is_action_just_pressed("slide") and has_slide,
		"throw" : Input.is_action_just_pressed("throw") and has_orb,
	}
	
	# process states
	state_machine.process_logc(delta)
	
	# move and slide
	var _collided = move_and_slide()
	
	# check for player throwing


func accelerate_horizontally():
	pass


