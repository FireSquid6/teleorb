extends StateMachineState
class_name PlayerStateFalling

@export var _coyote_timer: Timer
@onready var p: Player = get_parent().get_parent()

var in_coyote_time = false

func _ready():
	var stats = p.get_stats()
	_coyote_timer.wait_time = stats.coyote_time
	_coyote_timer.connect("timeout", _on_coyote_timer_timeout)

func on_physics_process(delta: float):
	var inputs = p.get_inputs()
	var stats = p.get_stats()
	
	if p.is_on_floor():
		fsm.change_state("Walking")
	
	if in_coyote_time and inputs.jump_pressed:
		fsm.change_state("Jumping")
		
	
	p.handle_horizontal_movement(stats.airstrafing_acceleration * delta, stats.airstopping_acceleration * delta, inputs.move_direction, stats.max_walk_speed, false)
	p.velocity.y += stats.fall_gravity * delta


func _on_walking_coyote_time() -> void:
	in_coyote_time = true
	_coyote_timer.start()


func _on_coyote_timer_timeout() -> void:
	in_coyote_time = false
