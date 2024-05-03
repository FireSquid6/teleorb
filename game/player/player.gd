extends CharacterBody2D
class_name Player

@export var initial_stats: PlayerStats
@export var _inputs: PlayerInputs
@export var _left_wall_detector: Area2D
@export var _right_wall_detector: Area2D
@onready var fsm: FiniteStateMachine = $FiniteStateMachine

var _stats: PlayerStats
var id := -1  # multiplayer peer id
var gravity_direction := 1

var orbs_thrown = 0
var orb_thrown = false
var orb: Orb = null
var has_orb = true
var level: Level

var _camera_scene = preload("res://player/camera.tscn")

func _set_stats(stats: PlayerStats):
	_stats = stats

func _enter_tree():
	# todo: make this not terrible
	level = get_parent().get_parent()
	
	_set_stats(initial_stats)
	
	id = str(name).to_int()
	set_multiplayer_authority(id)


func throw_orb() -> bool:
	if not (has_orb and not orb_thrown):
		return false
	
	has_orb = false
	orb_thrown = true
	
	var orb_id := str(name) + "-" + str(orbs_thrown)
	var direction = (get_global_mouse_position() - position).normalized()
	level.add_orb(self, direction, orb_id)
	
	orb = level.find_entity_by_name(orb_id)
	Log.out("Found orb: " + str(orb))
	
	orb.connect("hit", _on_orb_hit)
	orb.connect("destroyed", _on_orb_destroyed)
	orbs_thrown += 1
	

	return true


func _on_orb_hit(pos: Vector2):
	position = pos
	
	_deref_orb()


func _on_orb_destroyed(_pos: Vector2):
	Log.out("destroyed")
	
	_deref_orb()


func _deref_orb():
	orb.disconnect("destroyed", _on_orb_destroyed)
	orb.disconnect("hit", _on_orb_hit)
	orb_thrown = false
	orb = null

func _ready() -> void:
	if is_multiplayer_authority():
		add_child(_camera_scene.instantiate())

func _physics_process(delta: float) -> void:
	# players that aren't the multiplayer authority do not do any physics processing
	if !is_multiplayer_authority():
		return
	_inputs.update()
	
	if _inputs.throw_pressed:
		throw_orb()
	fsm.physics_process(delta)
	
	move_and_slide()


func get_inputs() -> PlayerInputs:
	# this is a private "read only" variable so that no other objects can set it
	return _inputs


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


func walljump(vspd: float, hspd: float) -> int:
	velocity.y = vspd * -1
	var dir = 0
	if _area_overlaps(_left_wall_detector):
		dir = 1
	elif _area_overlaps(_right_wall_detector):
		dir = -1
	else:
		push_error("Error: tried to walljump while not on a wall")
		return 0
	
	velocity.x = hspd * dir
	return dir

func _area_overlaps(area: Area2D) -> bool:
	return area.get_overlapping_areas().size() > 0 or area.get_overlapping_bodies().size() > 0

func wants_walljump():
	var close_enough = _area_overlaps(_left_wall_detector) or _area_overlaps(_right_wall_detector)
	return close_enough and _inputs.walljump_pressed

func jump():
	velocity.y = _stats.jump_speed * -1

func _handle_walljump():
	if not is_on_wall():
		return
	

func _slow_down(stopping_acceleration: float):
	if abs(velocity.x) - stopping_acceleration < 0:
		velocity.x = 0
	else:
		velocity.x -= stopping_acceleration * sign(velocity.x)
