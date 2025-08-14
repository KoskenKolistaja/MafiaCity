extends StaticBody3D

var text = "Open"
var open = false






func activate():
	if is_multiplayer_authority():
		$CollisionShape3D.disabled = false


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
	
	if not is_multiplayer_authority():
		text = ""
