extends Area2D
class_name Interactable


signal interacted()
var key_showing := false
var hovered := false  # whether the player is hovering over the interactable or not
@export var locked := false  # if the interactable is locked, it cannot be interacted with
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _physics_process(delta) -> void:
	if Input.is_action_just_pressed("interact") and hovered:
		_interacted()
		emit_signal("intercted")


func _on_interactable_body_entered(_body = null):
	if !locked:
		hovered = true
		animation_player.play("fade")
		key_showing = true


func _on_interactable_body_exited(_body = null):
	if !locked:
		hovered = false
		animation_player.play_backwards("fade")
		key_showing = false


# virtual method
func _interacted():
	pass


# prevents this interactable from being interacted with
func lock():
	locked = true
	if key_showing:
		hovered = false
		key_showing = false
		animation_player.play_backwards("fade")

func unlock():
	locked = false
