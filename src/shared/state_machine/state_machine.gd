extends Node
class_name StateMachine


var state_history := []  # the history of states
var possible_states := []  # the names of every possible state
var selected_state: State  # the currently selected state
@export_node_path(Node) var starting_state  # the state the machine starts on
@export var output_changes: bool = false  # whether the state machine outputs its changes or not
@export_range(0, 50) var max_state_history_length: int = 20  # the maximum length the state history can be


signal state_changed(old_state, new_state)  # emitted whenever the state is changed
signal logic_finished()  # emitted whenever the game logic is finished processing
signal supplementary_logic_finished()  # emitted whenever the supplementary logic is finished processing


func _ready() -> void:
	# get the possible states
	for child in get_children():
		child = child as Node
		possible_states.append(child.get_name())
	
	# start the initial state
	change_state(starting_state)


func change_state(new_state: String, enter_args := [], exit_args := []) -> bool:
	# make sure the new state is a possible state
	# some bug in godot 4 is causing this to fail
	# assert(new_state in possible_states)
	
	var old_name := "none"
	var new_name := "none"
	
	# exit out of the old state
	if get_state(new_state)._can_transition():
		if selected_state:
			# run the old state's exit function
			selected_state._exit(exit_args)
			selected_state.emit_signal("exitted")
			
			# edit the state history
			state_history.insert(0, selected_state.name)
			if len(state_history) > max_state_history_length:
					var _end_state = state_history.pop_back()
			
			old_name = selected_state.name
		
		# enter into the new state
		selected_state = get_state(new_state)
		selected_state._enter(enter_args)
		new_name = selected_state.name
		selected_state.emit_signal("entered")
		
		# output debug
		if output_changes:
			print("Switched from " + old_name + " to " + new_name)
		
		# emit signals
		emit_signal('state_changed', old_name, new_name)
		
		return true
		
	if output_changes:
		print('State Change Failed')
	return false


func process_logc(delta) -> void:
	selected_state._logic(delta)
	emit_signal('logic_finished')


func process_supplementary_logic() -> void:
	selected_state._supplementary_logic()
	emit_signal('supplementary_logic_finished')


func get_state(state_name) -> State:
	return get_node(state_name)
