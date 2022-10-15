extends AnimatedSprite2D
class_name PlayerSprite


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
		if decision_data["on_wall"]:
			new_animation = 'wall'
	else:
		Console.output("Unknown state '{0}' given to player sprite.".format([state]))
	
	# change anim
	if new_animation != animation:
		animation = new_animation
		return true
	
	return false
