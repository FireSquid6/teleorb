class_name Checkpoint
extends Interactable
# checkpoint object. The player can interact with it to set it as the new spawnpoint


@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _spawn_pos: Vector2 = $SpawnPos.global_position


# TODO: make the enabling and disabling of the checkpoint two different functions
# TODO: add vfx for the checkpoint being interacted with
func _interacted():
	var player: Player = get_tree().current_scene.player
	
	if player.current_checkpoint != null:
		player.current_checkpoint.unlock()
		player.current_checkpoint.sprite.frame = 0
	
	player.current_checkpoint = self
	player.respawn_point = _spawn_pos
	
	lock()
	_sprite.frame = 1
