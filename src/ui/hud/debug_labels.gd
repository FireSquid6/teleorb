extends VBoxContainer


var labels := []  # list of debug labels


# adds a new debug label
# automatically tracks the property
func add_debug_label(object: Object, property_name: String, custom_label: String = "") -> void:
	var node := Label.new()
	add_child(node)
	labels.append(DebugLabel.new(object, property_name, node, custom_label))


func _process(_delta) -> void:
	for label in labels:
		label = label as DebugLabel
		label.update()


# class for each debug label
class DebugLabel:
	var object: Object
	var property_name: String
	var label: String 
	var node: Label
	
	func _init(object: Object, property_name: String, node: Label, custom_label: String = ""):
		self.object = object
		self.property_name = property_name
		self.label = property_name + ": "
		if custom_label != "":
			self.label = custom_label
		self.node = node
	
	func update() -> void:
		var value = object.get(property_name)
		node.text = label + str(value)
