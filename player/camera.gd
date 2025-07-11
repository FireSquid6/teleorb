extends Camera2D


var areas: Array[Rect2] = []
var current_area: Rect2


func _ready() -> void:
	var stack: Array[Node] = [get_tree().root]
	
	while len(stack) > 0:
		var node: Node = stack.pop_back()
		
		for c in node.get_children():
			stack.append(c)
		
		if node.has_method("is_camera_area"):
			node = node as CameraArea
			if node.is_camera_area():
				areas.append(node.consume())
	
	if len(areas) > 0:
		set_area(areas[0])


func _physics_process(_delta: float) -> void:
	if len(areas) < 0:
		return
	
	if not current_area.has_point(global_position):
		var found = false
		no_area()
		for area in areas:
			if area.has_point(global_position):
				set_area(area)
				break
		


func set_area(area: Rect2) -> void:
	current_area = area
	
	limit_left = area.position.x
	limit_top = area.position.y
	limit_right = area.end.x
	limit_bottom = area.end.y


func no_area() -> void:
	current_area = Rect2(0, 0, 0, 0)
	
	limit_left = -1000000000
	limit_right = 1000000000
	limit_top = -1000000000
	limit_bottom = 1000000000
	
