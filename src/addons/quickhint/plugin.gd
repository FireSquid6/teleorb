@tool
extends EditorPlugin
class_name QuickHint


static func load_input_image(event: InputEvent) -> Texture:
	var images_path: String = "res://addons/quickhint/images/"
	
	var texture: Texture
	var dir: DirAccess = DirAccess.open(images_path)
	var filepath: String = ""
	
	if event as InputEventJoypadButton:
		event = event as InputEventJoypadButton
		filepath = images_path + "button_" + str(event.button_index) + ".png"
		
		
	elif event as InputEventJoypadMotion:
		event = event as InputEventJoypadMotion
		filepath = images_path + "axis_" + str(event.axis) + ".png"
		
		
	elif event as InputEventMouseButton:
		event = event as InputEventMouseButton
		filepath = images_path + "mouse_" + str(event.button_index) + ".png"
		
		
		
	elif event as InputEventKey:
		event = event as InputEventKey
		filepath = images_path + "key_" + event.as_text().to_lower() + ".png"
		
		
	
	if dir.file_exists(filepath) and filepath != "":
		return load(filepath)
	
	return null
	
