extends Node3D


func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		
		print(body.player_id)
		print(multiplayer.get_unique_id())
		
		if body.player_id == multiplayer.get_unique_id():
			fade_out()


func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		if body.player_id == multiplayer.get_unique_id():
			fade_in()






func fade_out():
	$AnimationPlayer.play("fade_out")



func fade_in():
	$AnimationPlayer.play("fade_in")
