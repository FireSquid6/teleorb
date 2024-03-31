extends StateMachineState

@onready var p: Player = get_parent().get_parent()
@export var _jumping_timer: Timer

func _ready() -> void:
	var stats = p.get_stats()
	_jumping_timer.wait_time = stats.jump_time
	_jumping_timer.connect("timeout", _on_jumping_timer_timeout)

func _on_jumping_timer_timeout() -> void:
	fsm.change_state("Falling")

func on_enter():
	var inputs = p.get_inputs()
	var stats = p.get_stats()
	
	inputs.walljump_buffer.consume()
	inputs.jump_buffer.consume()
	
	var dir = p.walljump(stats.walljump_vertical_speed, stats.walljump_horizontal_speed)
	inputs.force_direction(stats.walljump_cancel_time, dir * -1)


func on_physics_process(delta: float) -> void:
	var inputs = p.get_inputs()
	var stats = p.get_stats()
	
	if not inputs.jump_held:
		fsm.change_state("Falling")
		return
	
	p.velocity.y += stats.jump_gravity * delta
	print(p.velocity.y)
	
	if p.velocity.y >= 0:
		fsm.change_state("Falling")
		return
