extends Node
class_name State


signal entered()  # emitted when this state is entered into
signal exitted()  # emitted when this state is exited
var active_signals := []  # list of active signal objects
@onready var machine: StateMachine = get_parent() 

# virtual method for chaning the state
# called by the state machine when another state requests to change into this state. If it returns false, the change is aborted.
func _can_transition() -> bool:
	return true


# runs whenever this state is entered into
func _enter(args := []) -> void:
	pass


# runs whenever this state is exited. Runs before the previous state is entered.
func _exit(args := []) -> void:
	pass


# executed whenever the process_logic() method on the state machine is called
func _logic(delta: float = -1.0) -> void:
	pass


# executted whenever the process_supplementary_logic() method on the state_machine is called
func _supplementary_logic() -> void:
	pass


# same as _input(), but is only called when active
func _active_input(event: InputEvent) -> void:
	pass


# adds a signal that is activated and deactivated based on when this state is active
func _add_active_signal(signaler: Object, signal_name: String, method: Callable):
	var active_signal: ActiveSignal = ActiveSignal.new(signaler, signal_name, method)
	connect('entered', Callable(active_signal, '_on_State_entered'))
	connect('exited', Callable(active_signal, '_on_State_exited'))


class ActiveSignal:
	var signaler: Object
	var signal_name: String
	var method: Callable
	
	func _init(_signaler: Object, _signal_name: String, _method: Callable):
		#setup names
		signaler = _signaler
		signal_name = _signal_name
		method = _method
	
	func _on_State_entered():
		return signaler.connect(signal_name, method)
	
	
	func _on_State_exited():
		return signaler.disconnect(signal_name, method)
