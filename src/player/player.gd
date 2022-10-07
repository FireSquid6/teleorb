extends CharacterBody2D
class_name Player


# debug stuff
var on_wall = false
var current_state = ""
var move = 0

# whether the player has access to certain items
var has_dash: bool = false
var has_slide: bool = false
var has_orb: bool = false

var walljumps_left: int = 0  # the amount of walljumps the player has left
var jump_buffered: bool = false  # whether a jump input has been buffered or not
var walljump_buffered: bool = false  # whether a walljump is buffered or not
var canceled_input: int = 0  # input direction canceled. If 0, not inputs are canceled

var can_throw := false  # whether the player has an orb to throw
var orb_thrown := false  # whether the orb is currently in the air or not

@export_group("X Movement")
@export var running_speed: float = 200  # the maximum speed the player can accelerate to
@export var acceleration: float = 4800  # the speed the player accelerates at
@export var deceleration: float = 4800  # the speed the player slows down at
@export var max_walljumps: int = 1  # the maximum amount of times the player can walljump
@export var walljump_spd: float = 200

@export_group("Y Movement")
@export var jump_spd: float = 200 # the speed that the player jumps at
@export var jump_time: float = 0.3  # the amount of time the player jumps for
@export var jump_grv: float = 450  # the gravity during jumps
@export var grv: float = 900  # standard gravity
@export var air_resistance: float = 1  # percent movement is reduced by when moving in air
@export var cyote_time: float = 0.1  # the amount of time the player can still jump while falling
@export var terminal_velocity: float = 10000  # the maximum velocity the player can reach traveling downwards

@export_group("Orb")
@export var orb_speed: float = 500

@onready var input: Dictionary = {}  # dictionary for the input each frame
@onready var state_machine: StateMachine = get_node('StateMachine')  # ref to state machine
@onready var sprite: AnimatedSprite2D = get_node("AnimatedSprite2d")  # ref to the animated sprite
@onready var walljump_buffer_area: Area2D = $WalljumpBuffer  # ref to the walljump bufer area
@onready var jump_buffer_area: Area2D = get_node('JumpBufferCollision')  # ref to the area that handles the jump buffer
@onready var input_cancel_timer: Timer = $Timers/InputCancelTime  # timer for canceling inputs
@onready var orb_scene := preload("res://player/orb/orb.tscn")  # scene instanced for spawning the orb


func _physics_process(delta):
	on_wall = is_on_wall()
	
	# get input
	# TODO: abstract this more
	move = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	if canceled_input != 0:
		move = canceled_input * -1
	
	input = {
		"move" : move,
		"dash" : Input.is_action_just_pressed("dash") and has_dash,
		"slide" : Input.is_action_just_pressed("slide") and has_slide,
		"throw" : Input.is_action_just_pressed("throw") and has_orb,
		"jump_pressed" : Input.is_action_just_pressed("jump"),
		"jump" : Input.is_action_pressed("jump"),
		"angle" : global_position.angle_to(get_global_mouse_position()),
	}
	
	# process states
	state_machine.process_logc(delta)
	current_state = state_machine.selected_state.name
	
	# move and slide
	var collided = move_and_slide()
	if collided:
		canceled_input = 0
	
	# check for player throwing
	# TODO: Abstract this more
	if input["throw"] and has_orb and can_throw and !orb_thrown:
		# set booleans
		orb_thrown = true
		has_orb = false
		
		# create the orb
		var orb: Orb = orb_scene.instantiate()
		orb.velocity = Vector2(orb_speed, 0).rotated(input["angle"])
		add_child(orb)
		
		# move to teleport state
		


#func run(delta: float, dir: int, decelerate_above_max_speed: bool = false, acceleration_multiplier: float = 1.0) -> void:
#	# set animation player xscale to move
#	if move != 0:
#		sprite.scale.x = move
#
#	# get deceleration and acceleration
#	var dec := deceleration * delta
#	var acc := acceleration * delta
#
#	# accelerate if moving
#	if dir != 0:
#		# decelerate if aboce maximum speed
#		if (abs(velocity.x) >= running_speed):
#			if decelerate_above_max_speed and (abs(velocity.x) - dec) > running_speed:
#				velocity.x -= dec * dir
#			else:
#				velocity.x = sign(velocity.x) * running_speed
#		else:
#			velocity.x += acc * acceleration_multiplier * dir
#			if !decelerate_above_max_speed:
#				velocity.x = clamp(velocity.x, -running_speed, running_speed)
#	# decelerate if not moving
#	else:
#		# snap velocity to 0 if needed
#		if abs(velocity.x) <= dec * acceleration_multiplier:
#			velocity.x = 0
#		else:
#			velocity.x -= acc * acceleration_multiplier * sign(velocity.x)

#// deceleration
#if velocity > max speed:
#  velocity -= deceleration * sign(velocity)
#  if abs(velocity) < max speed:
#    velocity = max_speed * sign(velocity)
#
#// acceleration
#if velocity < max speed:
#  velocity += deceleration * dir
#  if abs(velocity) > max speed:
#    velocity = max_speed * dir

func run(delta: float, dir: int, decelerate_if_above_max_speed: bool = false, acceleration_multiplier: float = 1.0) -> void:
	# set animation player xscale to move
	if move != 0:
		sprite.scale.x = move

	# get deceleration and acceleration
	var dec := deceleration * delta
	var acc := acceleration * delta
	
	# decelerate
	print("frick")
	if ((velocity.x > running_speed) and decelerate_if_above_max_speed) or (dir == 0):
		if abs(velocity.x) - dec <= 0:
			velocity.x = 0 
		else:
			velocity.x -= dec * sign(velocity.x)
		
		print("Decelerating!")
	
	# accelerate
	if velocity.x <= running_speed and dir != 0:
		if abs(velocity.x) + acc <= running_speed:
			velocity.x += acc * dir
		elif sign(velocity.x) == dir:
			# note to future self: this line is the problem
			velocity.x = running_speed * sign(velocity.x)
		else:
			velocity.x += acc * dir
		
		print("Accelerating")
	


# stops an input from being pressed for a given amount of time
func cancel_dir(dir: int):
	canceled_input = dir
	input_cancel_timer.start()


func _on_input_cancel_time_timeout():
	canceled_input = 0


func _on_level_level_loaded(level: Level):
	level.hud.add_debug_label(self, "velocity", "V = ")
	level.hud.add_debug_label(self, "on_wall", "OnWall = ")
	level.hud.add_debug_label(self, "current_state", "State = ")
	level.hud.add_debug_label(self, "move", "Move = ")
	level.hud.add_debug_label(self, "canceled_input", "Canceled Direction = ")
