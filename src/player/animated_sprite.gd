class_name PlayerSprite
extends AnimatedSprite2D
# the player's animated sprite
# it will choose a new animation based on a decision data dictionary provided by the player



const decision_data_template = {
	"state": "StateMoving",
	"on_wall": false,
	"move": 0,
}

var cached_decision_data: Dictionary = {}

# runs through logic to pick the new animation
# this function will have to be updated frequently
func choose_animation(decision_data: Dictionary, forced := false) -> bool:
	# make sure that no lazy programmers forgot a key
	for key in decision_data.keys():
		if !decision_data.has(key):
			decision_data[key] = decision_data_template[key]
	
	# abort if same decision data as last time
	if cached_decision_data.hash() == decision_data.hash():
		return false
	
	cached_decision_data = decision_data.duplicate()
	
	# logic
	var new_animation = 'midair'
	var new_playing = true
	var state = decision_data["state"]
	
	# note - this is a bad elif chain because match statements were broken at the time
	# TODO: add 
	if state == 'StateMoving':
		new_animation = 'walking'
		if decision_data["move"] == 0:
			new_animation = 'idle'
	elif state =="StateTeleport":
		new_animation = 'teleport'
	elif state == "StateJumping":
		new_animation = 'midair'
	elif state == "StateFalling":
		new_animation = 'midair'
	elif state == "StateWallgrab":
		new_animation = 'wall'
	elif state == "StateDead":
		new_animation = 'die'
	else:
		Console.output("Unknown state '{0}' given to player sprite.".format([state]))
	
	# change anim
	if new_animation != animation:
		animation = new_animation
		if new_playing != playing:
			playing = new_playing
		return true
	
	return false
