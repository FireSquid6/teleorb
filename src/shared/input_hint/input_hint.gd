extends Object
# this static class is used to generate input hint textures
# it shouldn't ever need to be instanced

# TODO: make this a singleton
class_name InputHint


# no support for 0-9 numbers
# move this to a toml file?
const KEYBOARD_BASE = {
	KEY_UP : Vector2i(0, 0),
	KEY_DOWN : Vector2i(0, 1),
	KEY_LEFT : Vector2i(0, 2),
	KEY_RIGHT : Vector2i(0, 3),
	KEY_F1 : Vector2i(0, 4),
	KEY_F2 : Vector2i(0, 5),
	KEY_F3 : Vector2i(0, 6),
	KEY_F4 : Vector2i(0, 7),
	KEY_F5 : Vector2i(1, 0),
}

# TODO: add controller buttons

# returns an image containing the specified key or button
# "key" should be one of the key constants
static func get_key_image(key: int, pressed: bool = false, ):
	var keyboard_base: Texture2D = preload("res://shared/input_hint/keyboard_base.png")
	var keyboard_extras: Texture2D = preload("res://shared/input_hint/keyboard_extras.png")
	
	
# How this should work:
# takes the name of an input action and the current control type (probably an enum?) as inputs for the function
# returns a texture as the output
# uses the events in that action combined with the current control state to decide what image to return
# InputEvent.get_text()?
