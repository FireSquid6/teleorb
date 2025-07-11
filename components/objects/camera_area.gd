extends CollisionShape2D
class_name CameraArea


func consume() -> Rect2:
	var rect_size: Vector2 = shape.get_rect().size
	
	return Rect2(global_position - rect_size / 2, rect_size)


# the player's camera searchs the tree recursively for objects with this method
# anything that returns true will be assumed to be a camera area
func is_camera_area() -> bool:
	return true
