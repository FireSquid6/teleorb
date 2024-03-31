extends Node
class_name PlayerInputs

var move_direction: int = 0
var jump_pressed: bool = false
var walljump_pressed: bool = false  # this is different from jump pressed for buffer processing reasons
var jump_held: bool = false
var slide_pressed: bool = false
var slide_held: bool = false

@export var jump_buffer: InputBuffer
@export var walljump_buffer: InputBuffer

@export var _force_timer: Timer
var forced = false
var forced_dir = 0 


func _ready():
	_force_timer.connect("timeout", _on_force_timer_timeout)

func force_direction(t: float, dir: int):
	_force_timer.wait_time = t
	_force_timer.start()
	forced = true
	forced_dir = dir

func _on_force_timer_timeout():
	forced = false

func update():
	jump_buffer.update()
	
	jump_pressed = jump_buffer.buffered
	if not jump_pressed:
		jump_pressed = Input.is_action_just_pressed("jump")
	
	walljump_pressed = walljump_buffer.buffered
	if not walljump_pressed:
		walljump_pressed = Input.is_action_just_pressed("jump")
	
	jump_held = Input.is_action_pressed("jump")
	
	if forced:
		move_direction = forced_dir
	else:
		var right = int(Input.is_action_pressed("right"))
		var left = int(Input.is_action_pressed("left"))
		move_direction = right - left
	
	slide_pressed = Input.is_action_just_pressed("slide")
	slide_held = Input.is_action_pressed("slide")
