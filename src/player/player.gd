extends CharacterBody2D
class_name Player


# whether the player has access to certain items
var has_dash: bool = false
var has_slide: bool = false
var has_orb: bool = false

var walljumps_left: int = 0  # the amount of walljumps the player has left
var jump_buffered: bool = false  # whether a jump input has been buffered or not
var walljump_buffered: bool = false  # whether a walljump is buffered or not
var canceled_input: int = 0

@export var running_speed: float = 500  # the maximum speed the player can accelerate to
@export var acceleration: float = 2000  # the speed the player accelerates at
@export var deceleration: float = 1500  # the speed the player slows down at
@export var max_walljumps: int = 1  # the maximum amount of times the player can walljump
@export var walljump_spd: float = 500
@export var jump_spd: float = 500  # the speed that the player jumps at
@export var jump_time: float = 0.25  # the amount of time the player jumps for
@export var jump_grv: float = 100  # the gravity during jumps
@export var grv: float = 200  # standard gravity
@export var air_resistance: float = 0.0  # percent movement is reduced by when moving in air
@export var cyote_time: float = 0.1  # the amount of time the player can still jump while falling
@export var terminal_velocity: float = 10000  # the maximum velocity the player can reach traveling downwards

@onready var input: Dictionary = {}  # dictionary for the input each frame
@onready var state_machine: StateMachine = get_node('StateMachine')  # ref to state machine
@onready var sprite: AnimatedSprite2D = get_node("AnimatedSprite2d")  # ref to the animated sprite
@onready var jump_buffer_area: Area2D = get_node('JumpBufferCollision')  # ref to the area that handles the jump buffer
@onready var input_cancel_timer: Timer = $Timers/InputCancelTime  # timer for canceling inputs


func _physics_process(delta):
	# get input
	input = {
		"move" : int(Input.is_action_pressed("move_right") and canceled_input != 1) - int(Input.is_action_pressed("move_left") and canceled_input != -1),
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


# stops an input from being pressed for a given amount of time
func cancel_dir(dir: int):
	canceled_input = dir
	input_cancel_timer.start()


func _on_input_cancel_time_timeout():
	canceled_input = 0
