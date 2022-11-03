extends Area2D
class_name Interactable


signal interacted()
var _key_showing := false  
var hovered := false  # whether the player is hovering over the interactable or not
@export var locked := false  # if the interactable is locked, it cannot be interacted with
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _key_image: Sprite2D = $Key


func _ready():
	var event: InputEvent = InputMap.action_get_events("interact")[0]
	
	_key_image.texture = QuickHint.load_input_image(event)

func _physics_process(delta) -> void:
	if Input.is_action_just_pressed("interact") and hovered:
		_interacted()
		emit_signal("intercted")


func _on_interactable_body_entered(_body = null):
	if !locked:
		hovered = true
		_animation_player.play("fade")
		_key_showing = true


func _on_interactable_body_exited(_body = null):
	if !locked:
		hovered = false
		_animation_player.play_backwards("fade")
		_key_showing = false


# virtual method
func _interacted():
	pass


# prevents this interactable from being interacted with
func lock():
	locked = true
	if _key_showing:
		hovered = false
		_key_showing = false
		_animation_player.play_backwards("fade")

func unlock():
	locked = false
