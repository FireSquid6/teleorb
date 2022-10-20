extends Interactable
class_name Checkpoint


@onready var sprite: AnimatedSprite2D = $Sprite
@onready var spawn_pos: Vector2 = $SpawnPos.global_position


# TODO: make the enabling and disabling of the checkpoint two different functions
# TODO: add vfx for the checkpoint being interacted with
func _interacted():
	var player: Player = get_tree().current_scene.player
	
	if player.current_checkpoint != null:
		player.current_checkpoint.unlock()
		player.sprite.frame = 0
	
	player.current_checkpoint = self
	player.respawn_point = spawn_pos
	
	lock()
	sprite.frame = 1
