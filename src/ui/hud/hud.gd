extends CanvasLayer
class_name HUD


@onready var debug_label_container: Control = $DebugLabels


# forwards a request to add a debug labeld
func add_debug_label(object: Object, property_name: String, custom_label: String = ""):
	debug_label_container.add_debug_label(object, property_name, custom_label)
