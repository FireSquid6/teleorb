extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var id = -1  # multiplayer peer id

func _enter_tree():
	id = str(name).to_int()
	set_multiplayer_authority(id)

func _ready() -> void:
	if is_multiplayer_authority():
		$Camera2D.enabled = true
		$Sprite2D.modulate = Color(0, 1, 0)
	$Label.text = str(name)

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
