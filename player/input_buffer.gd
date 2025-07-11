extends Node
class_name InputBuffer

@export var input_name: String
@export var _buffer_area: Area2D
var _listening = false
var buffered = false

func update():
	if not _listening or buffered:
		return
	
	var in_range = _buffer_area.get_overlapping_areas().size() > 0 or _buffer_area.get_overlapping_bodies().size() > 0
	var pressed = Input.is_action_just_pressed(input_name)
	
	if in_range and pressed:
		buffered = true


func listen():
	_listening = true

func cancel():
	buffered = false
	_listening = false


func consume() -> bool:
	if buffered and _listening:
		_listening = false
		buffered = false
		return true
		
	return false
