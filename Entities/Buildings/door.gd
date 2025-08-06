extends StaticBody3D

var text = "Open"
var open = false





func action():
	if is_multiplayer_authority():
		open_door.rpc()
	else:
		text = ""

@rpc("any_peer","call_local","reliable")
func open_door():
	if open:
		$AnimationPlayer.play("close")
		text = "Open [E]"
		open = false
	else:
		$AnimationPlayer.play("open")
		text = "Close [E]"
		open = true
