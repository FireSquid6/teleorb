extends Node2D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _process(delta):
	# move to the mouse
	position = get_global_mouse_position()


func set_color(new_color: Color):
	modulate = new_color
