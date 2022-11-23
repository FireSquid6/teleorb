extends Node2D
# global singleton that handles the cursor


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _process(delta) -> void:
	# move to the mouse
	position = get_global_mouse_position()


func set_color(new_color: Color) -> void:
	modulate = new_color
