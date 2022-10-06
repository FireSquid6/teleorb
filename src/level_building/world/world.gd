extends Node2D
class_name World


@onready var areas: Node2D = $Areas


func _ready():
	areas.visible = false
