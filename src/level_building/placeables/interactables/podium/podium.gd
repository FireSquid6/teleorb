extends Interactable


@onready var sprite: AnimatedSprite2D = $Podium


func _interacted():
	lock()
	
	var player: Player = get_tree().current_scene.player
	match sprite.frame:
		1:
			player.has_orb = true
		_:
			Console.terminate("[color=red]Some messed up stuff is happening. Look in \"res://level_building/interactables/podium/podium.gd\". The podium had a frame of {0} when interacted with[/color]".format([sprite.frame]))
	
	sprite.frame = 0
	
