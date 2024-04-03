@icon("../icons/state_machine_state.svg")
extends StateMachineState
class_name PlayerStateWalking

@onready var p: Player = get_parent().get_parent()

signal coyote_time


func on_physics_process(delta: float) -> void:
	var inputs = p.get_inputs()
	if inputs.jump_pressed:
		fsm.change_state("Jumping")
		return
	
	if not p.is_on_floor():
		coyote_time.emit()
		fsm.change_state("Falling")
		return
	
	var stats = p.get_stats()
	
	p.handle_horizontal_movement(stats.walking_acceleration * delta, stats.stopping_acceleration * delta, inputs.move_direction, stats.max_walk_speed, true)


func on_enter() -> void:
	var inputs = p.get_inputs()
	p.has_orb = true
	#inputs.walljump_buffer.cancel()
	#inputs.jump_buffer.cancel()
