extends CharacterBody2D
class_name Player


# whether the player has access to certain items
var has_dash: bool = false
var has_slide: bool = false
var has_orb: bool = false

var walljumps_left = 0  # the amount of walljumps the player has left

@export var running_speed: float = 500  # the maximum speed the player can accelerate to
@export var acceleration: float = 2000  # the speed the player accelerates at
@export var deceleration: float = 1500  # the speed the player slows down at
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
		"jump_pressed" : Input.is_action_just_released("jump"),
		"jump" : Input.is_action_pressed("jump")
	}
	
	# process states
	state_machine.process_logc(delta)
	
	# move and slide
	var _collided = move_and_slide()
	
	# check for player throwing


# accelerates this object's horizontal velocity based on acceleration, deceleration, 
# dir - the direction to accelerate in
# decelerate_above_max_speed - whether to decelerate the velocity if the 
func run(dir: int, decelerate_above_max_speed: bool = false, acceleration_multiplier: float = 1.0) -> void:
	# accelerate if moving
	if dir != 0:
		# decelerate if aboce maximum speed
		if (abs(velocity.x) > running_speed):
			if decelerate_above_max_speed:
				velocity.x -= deceleration * acceleration_multiplier * sign(velocity.x)
		else:
			velocity.x += acceleration * acceleration_multiplier * dir
			if !decelerate_above_max_speed:
				velocity.x = clamp(velocity.x, -running_speed, running_speed)
	# decelerate if not moving
	else:
		# snap velocity to 0 if needed
		if abs(velocity.x) <= deceleration * acceleration_multiplier:
			velocity.x = 0
		else:
			velocity.x -= deceleration * acceleration_multiplier * sign(velocity.x)


