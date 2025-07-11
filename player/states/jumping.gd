extends StateMachineState
class_name PlayerStateJumping

@onready var p: Player = get_parent().get_parent()
@export var _jumping_timer: Timer
var _hit_speed = false

func _ready() -> void:
	var stats = p.get_stats()
	_jumping_timer.wait_time = stats.jump_time
	_jumping_timer.connect("timeout", _on_jumping_timer_timeout)

func on_enter() -> void:
	var inputs = p.get_inputs()
	_hit_speed = false
	
	_jumping_timer.start()
	p.jump()
	
	inputs.walljump_buffer.consume()
	inputs.walljump_buffer.listen()
	inputs.jump_buffer.consume()

func on_physics_process(delta: float) -> void:
	var inputs = p.get_inputs()
	var stats = p.get_stats()
	
	if not inputs.jump_held:
		fsm.change_state("Falling")
		return
	
	if p.wants_walljump():
		fsm.change_state("Walljumping")
	
	p.velocity.y += stats.jump_gravity * delta
	
	if p.velocity.y >= 0:
		fsm.change_state("Falling")
		return


func _on_jumping_timer_timeout() -> void:
	fsm.change_state("Falling")
