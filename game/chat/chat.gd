extends Node

signal message_recieved(msg: String)

@rpc("any_peer", "call_local", "reliable")
func _send_message(msg: String):
	Log.out(msg)
	emit_signal("message_recieved", msg)

func send_message(msg: String):
	_send_message.rpc(msg)
