extends CharacterBody2D
class_name Player

@export var initial_stats: PlayerStats
var _stats: PlayerStats
@export var _buffer: Area2D

var id = -1  # multiplayer peer id

@onready var fsm: FiniteStateMachine = $FiniteStateMachine

func _set_stats(stats: PlayerStats):
	_stats = stats

func _enter_tree():
	_set_stats(initial_stats)
	
	id = str(name).to_int()
	set_multiplayer_authority(id)

func _ready() -> void:
	if is_multiplayer_authority():
		$Camera2D.enabled = true
		$Sprite2D.modulate = Color(0, 1, 0)
	$Label.text = str(name)

func _physics_process(delta: float) -> void:
	# players that aren't the multiplayer authority do not do any physics processing
	# this will be changed later
	if !is_multiplayer_authority():
		return
	
	fsm.physics_process(delta)
	$Label.text = str(velocity.x) + "\n" + str(velocity.y) + "\n" + str(fsm.current_state.name)
	
	move_and_slide()


func get_inputs() -> PlayerInputs:
	var inputs = PlayerInputs.new()
	
	inputs.move_direction = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	inputs.jump_pressed = Input.is_action_just_pressed("jump")
	inputs.jump_held = Input.is_action_pressed("jump")
	inputs.jump_buffered = false # TODO
	inputs.slide_held = Input.is_action_pressed("slide")
	inputs.slide_buffered = false # TODO
	
	return inputs


func get_stats() -> PlayerStats:
	return _stats


# does not apply delta to provided values
# all speed and acceleration values should not be negative
func handle_horizontal_movement(moving_acceleration: float, stopping_acceleration: float, move_direction: int, max_speed: float, slow_past_max_speed: bool):
	# ugly function. Should probably be something smarter
	# if player movement is broken, here's why
	if move_direction == 0:
		# move velocity close to 0
		_slow_down(stopping_acceleration)
	else:
		if velocity.x == 0:
			velocity.x += moving_acceleration * move_direction
		
		elif sign(velocity.x) == move_direction:
			if abs(velocity.x) > max_speed:
				if slow_past_max_speed:
					_slow_down(stopping_acceleration)
			else:
				if abs(velocity.x) + moving_acceleration > max_speed:
					velocity.x = max_speed * move_direction
				else:
					velocity.x += moving_acceleration * move_direction
		else:
			_slow_down(moving_acceleration)

func _slow_down(stopping_acceleration: float):
	if abs(velocity.x) - stopping_acceleration < 0:
		velocity.x = 0
	else:
		velocity.x -= stopping_acceleration * sign(velocity.x)

class PlayerInputs:
	var move_direction: int
	var jump_pressed: bool
	var jump_held: bool
	var jump_buffered: bool
	var slide_held: bool
	var slide_buffered: bool
