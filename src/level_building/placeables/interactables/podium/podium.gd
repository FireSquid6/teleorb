extends Interactable


@onready var sprite: AnimatedSprite2D = $Podium


func _on_interactable_interacted():
	self.locked = true
	
	var player: Player = get_tree().current_scene.player
	match sprite.frame:
		1:
			player.has_orb = true
		_:
			Console.terminate("[color=red][/color]")
	
	sprite.frame = 0
	
