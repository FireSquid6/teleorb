class_name GlobalClass
extends Node
# the main global singleton
# handles:
#  - inputs



# the current control method. Either keyboard, gamepad, or touch
var control_type := Constants.CONTROL_TYPE_KEYBOARD

# these values are used by the player to determine what direction the orb should be thrown in
# this should be refactored later
var right_axis_x := 0 
var right_axis_y := 0


func _input(event) -> void:
	if (event as InputEventJoypadMotion) or (event as InputEventJoypadButton):
		control_type = Constants.CONTROL_TYPE_GAMEPAD
		
		# if it's the right stick, make sure to grab the correct axis data
		if event as InputEventJoypadMotion:
			event = event as InputEventJoypadMotion
			match event.axis:
				JOY_AXIS_RIGHT_X:
					right_axis_x = event.axis_value
				JOY_AXIS_RIGHT_Y:
					right_axis_y = event.axis_value
			
	elif (event as InputEventKey) or (event as InputEventMouse):
		control_type = Constants.CONTROL_TYPE_KEYBOARD
