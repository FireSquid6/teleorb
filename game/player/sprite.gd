extends AnimatedSprite2D


var current_state = ""
@onready var player: Player = get_parent()


func _on_finite_state_machine_state_changed(new_state: StateMachineState) -> void:
	current_state = new_state.name

func _physics_process(_delta: float) -> void:
	if not player.is_multiplayer_authority():
		return
	
	var inputs = player.get_inputs()
	if inputs.move_direction != 0:
		if inputs.move_direction < 0:
			scale.x = -1
		else:
			scale.x = 1
	
	var new_anim = process_animation()
	if animation != new_anim:
		play(new_anim)
		

func process_animation() -> String:
	var on_wall = player.is_on_wall()
	var moving = player.velocity.length() > 0
	
	match current_state:
		"Walking":
			if moving:
				return "walking"
			return "idle"
		"Dying":
			return "dying"
		"Falling":
			if on_wall:
				return "wallriding"
	return "midair"
