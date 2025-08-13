extends Node3D


func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		$AnimationPlayer.play("fade_out")

func _on_area_3d_body_exited(body):
	$AnimationPlayer.play("fade_in")
