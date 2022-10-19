extends Area2D
class_name Interactable


signal interacted()
var key_showing := false
var hovered := false  # whether the player is hovering over the interactable or not
@export var locked := false :  # if the interactable is locked, it cannot be interacted with
	get:
		return locked
	set(value):
		# stupid workaround
		# should probably be changed
		locked = value
		if !locked and key_showing:
			hovered = false
			animation_player.playback_speed = -1

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _physics_process(delta) -> void:
	if Input.is_action_just_pressed("interact") and hovered:
		Console.output("Interacted with!")
		emit_signal("intercted")


func _on_interactable_body_entered(_body = null):
	hovered = true
	animation_player.play("fade")
	key_showing = true


func _on_interactable_body_exited(_body = null):
	hovered = false
	animation_player.play_backwards("fade")
	key_showing = false
