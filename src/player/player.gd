extends CharacterBody2D
class_name Player


# debug stuff
var on_wall = false
var on_floor = false
var on_floor_2 = false
var current_state = ""
var move = 0

# whether the player has access to certain items
var has_dash: bool = false
var has_slide: bool = false
var has_orb: bool = true

var walljumps_left: int = 0  # the amount of walljumps the player has left
var jump_buffered: bool = false  # whether a jump input has been buffered or not
var walljump_buffered: bool = false  # whether a walljump is buffered or not
var canceled_input: int = 0  # input direction canceled. If 0, not inputs are canceled

var can_throw := true  # whether the player has an orb to throw
var orb_thrown := false  # whether the orb is currently in the air or not

var level: Level = null  # ref to the current level

var mobile: bool = true
var default_input: Dictionary = {
	"move" : 0,
	"dash" : false,
	"slide" : false,
	"throw" : false,
	"jump_pressed" : false,
	"jump" : false,
	"angle" : false,
}

@export_group("X Movement")
@export var running_speed: float = 200  # the maximum speed the player can accelerate to
@export var acceleration: float = 3000  # the speed the player accelerates at
@export var deceleration: float = 2500  # the speed the player slows down at
@export var max_walljumps: int = 3  # the maximum amount of times the player can walljump
@export var walljump_spd: float = 200

@export_group("Y Movement")
@export var jump_spd: float = 225 # the speed that the player jumps at
@export var jump_time: float = 0.2  # the amount of time the player jumps for
@export var jump_grv: float = 600  # the gravity during jumps
@export var grab_grb: float = 200  # the gravity while wallgrabbing
@export var grv: float = 1200  # standard gravity
@export var air_resistance: float = 0.85  # percent movement is reduced by when moving in air
@export var cyote_time: float = 0.1  # the amount of time the player can still jump while falling
@export var terminal_velocity: float = 10000  # the maximum velocity the player can reach traveling downwards

@export_group("Orb")
@export var orb_speed: float = 500

@onready var input: Dictionary = {}  # dictionary for the input each frame
@onready var state_machine: StateMachine = get_node('StateMachine')  # ref to state machine
@onready var sprite: PlayerSprite = get_node("AnimatedSprite2d")  # ref to the animated sprite
@onready var walljump_buffer_area: Area2D = $WalljumpBuffer  # ref to the walljump bufer area
@onready var jump_buffer_area: Area2D = get_node('JumpBufferCollision')  # ref to the area that handles the jump buffer
@onready var input_cancel_timer: Timer = $Timers/InputCancelTime  # timer for canceling inputs
@onready var orb_scene := preload("res://player/orb/orb.tscn")  # scene instanced for spawning the orb
@onready var wall_detector: Area2D = $WallDetector
@onready var floor_detector: Area2D = $FloorDetector


func _enter_tree():
	level = get_parent()


func _ready():
	Console.connect("focused", Callable(self, "_on_Console_focused"))
	Console.connect("unfocused", Callable(self, "_on_Console_unfocused"))


func _physics_process(delta):
	on_wall = is_on_wall()
	
	# get input
	input = get_input()
	
	# process states
	var pre_floor = is_on_floor()
	
	state_machine.process_logc(delta)
	current_state = state_machine.selected_state.name
	
	on_floor = str(pre_floor) + " | " + str(is_on_floor())
	
	# move and slide
	var collided = move_and_slide()
	if collided:
		canceled_input = 0
	
	# process animations
	sprite.choose_animation({
		"move": move,
		"on_wall": is_on_wall(),
		"state": state_machine.selected_state.name,
	})
	
	# check for player throwing
	# TODO: Abstract this more
	if input["throw"]:
		throw_orb()


func get_input() -> Dictionary:
	# get move
	move = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	if canceled_input != 0:
		move = canceled_input * -1
	
	# get the angle to throw the orb at
	var angle := 0.0
	match Global.control_type:
		Constants.CONTROL_TYPE_KEYBOARD:
			angle = position.angle_to_point(level.cursor.position)
		Constants.CONTROL_TYPE_GAMEPAD:
			angle = Vector2(Global.right_axis_x, Global.right_axis_y).angle()
		Constants.CONTROL_TYPE_TOUCH:
			angle = 0
	
	# TODO: make this a class instead of a dict
	var new_input = {
		"move" : move,
		"dash" : Input.is_action_just_pressed("dash") and has_dash,
		"slide" : Input.is_action_just_pressed("slide") and has_slide,
		"throw" : Input.is_action_just_pressed("throw") and has_orb,
		"jump_pressed" : Input.is_action_just_pressed("jump"),
		"jump" : Input.is_action_pressed("jump"),
		"angle" : angle,
		"wallgrab" : Input.is_action_pressed("grab"),
	}
	if !mobile:
		new_input = default_input
	
	return new_input


func throw_orb():
	if can_throw and !orb_thrown:
		# set booleans
		orb_thrown = true
		can_throw = false
		
		# create the orb
		var orb: Orb = orb_scene.instantiate()
		orb.connect("hit", Callable(self, "_on_orb_hit"))
		orb.velocity = Vector2(orb_speed, 0).rotated(input["angle"])
		add_child(orb)


func run(delta: float, dir: int, decelerate_if_above_max_speed: bool = false, acceleration_multiplier: float = 1.0) -> void:
	# set animation player xscale to move
	if move != 0 and canceled_input == 0:
		sprite.scale.x = move

	# get deceleration and acceleration
	var dec := deceleration * delta * acceleration_multiplier
	var acc := acceleration * delta * acceleration_multiplier
	
	# make sure the player isn't in a wall
	var bodies := wall_detector.get_overlapping_bodies()
	if len(bodies) <= 0:
		# decelerate
		if ((velocity.x > running_speed) and decelerate_if_above_max_speed) or (dir == 0):
			if abs(velocity.x) - dec <= 0:
				velocity.x = 0 
			else:
				velocity.x -= dec * sign(velocity.x)
			
		
		# accelerate
		if velocity.x <= running_speed and dir != 0:
			if abs(velocity.x) + acc <= running_speed:
				velocity.x += acc * dir
			elif sign(velocity.x) == dir:
				# note to future self: this line is the problem
				velocity.x = running_speed * sign(velocity.x)
			else:
				velocity.x += acc * dir
	else:
		push_error("Player stuck in wall. Body: " + str(bodies))
	


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
	level.hud.add_debug_label(self, "on_floor", "OnFloor = ")


func _on_Console_focused():
	mobile = false


func _on_Console_unfocused():
	mobile = true


func _on_orb_hit(new_pos: Vector2):
	# move to state teleport
	state_machine.change_state("StateTeleport", [new_pos])
