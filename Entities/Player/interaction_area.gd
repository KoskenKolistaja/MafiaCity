extends Area3D


var paused




func _physics_process(delta):
	if is_multiplayer_authority() and not paused:
		
		var bodies = get_overlapping_bodies()
		
		
		if not bodies:
			$Label.hide()
			return
		
		var collider = bodies[0]
		
		if not collider.is_in_group("interactable"):
			return
		
		$Label.text = collider.text
		$Label.show()
		var camera = get_viewport().get_camera_3d()
		var collision_point = collider.global_position
		$Label.position = camera.unproject_position(collision_point)
		if Input.is_action_just_pressed('interact'):
			collider.action()
