extends RayCast3D








func _physics_process(delta):
	if not is_colliding():
		$Label.hide()
		return
	
	var collider = get_collider()
	
	if not collider.is_in_group("interactable"):
		return
	
	$Label.text = collider.text
	$Label.show()
	var camera = get_viewport().get_camera_3d()
	var collision_point = collider.global_position
	$Label.position = camera.unproject_position(collision_point)
	if Input.is_action_just_pressed('interact'):
		collider.action()
	
	
