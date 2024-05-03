extends CollisionShape2D
class_name CameraArea


func consume() -> Rect2:
	var rect = shape.get_rect()
	rect.position = global_position
	return rect


# the player's camera searchs the tree recursively for objects with this method
# anything that returns true will be assumed to be a camera area
func is_camera_area() -> bool:
	return true
