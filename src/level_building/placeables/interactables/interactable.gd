extends Area2D
class_name Interactable


signal interacted()
var hovered := false  # whether the player is hovering over the interactable or not

# TODO: track the hovered variable
# TODO: have the key object fade in and out based on hovered
# TODO: add outline?

func _physics_process(delta) -> void:
	if Input.is_action_just_pressed("interact") and hovered:
		Console.output("Interacted with!")
		emit_signal("intercted")
