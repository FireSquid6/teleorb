extends CharacterBody2D
class_name Player

enum PLAYER_STATE {MOVING, JUMPING, FALLING}

@export var stats: PlayerStats

var id = -1  # multiplayer peer id
var state = PLAYER_STATE.MOVING

func _enter_tree():
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
	
	match state:
		PLAYER_STATE.MOVING:
			_moving_state(delta)
			
	move_and_slide()

func _moving_state(delta: float):
	var move_direction = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	
	if abs()
	


