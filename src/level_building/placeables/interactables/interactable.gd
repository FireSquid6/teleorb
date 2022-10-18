extends Area2D
class_name Interactable


signal interacted()
var hovered := false  # whether the player is hovering over the interactable or not
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _physics_process(delta) -> void:
	if Input.is_action_just_pressed("interact") and hovered:
		Console.output("Interacted with!")
		emit_signal("intercted")


func _on_interactable_body_entered(_body):
	hovered = true
	animation_player.play("fade")


func _on_interactable_body_exited(body):
	hovered = false
	animation_player.play_backwards("fade")
