extends Camera2D


var areas: Array[Rect2] = []


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
	
