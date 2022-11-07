extends Node
# singleton for taking screenshots
# saves the screenshtos to user://screenshots/


const screenshots_directory := "user://screenshots/" 


func _init():
	if DirAccess.dir_exists_absolute(screenshots_directory):
		DirAccess.make_dir_absolute(screenshots_directory)


func take_screenshot():
	var time := Time.get_datetime_string_from_system()
	var texture: ViewportTexture = get_viewport().get_texture()
	var image: Image = texture.get_image()
	
	var dir: DirAccess = DirAccess.open(screenshots_directory)
	image.save_png(screenshots_directory + time + ".png")


func _process(delta):
	if Input.is_action_just_pressed("screenshot"):
		take_screenshot()
