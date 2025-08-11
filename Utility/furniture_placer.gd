extends Node3D


var building_size




func _ready():
	var player = get_tree().get_first_node_in_group("player")
	
	player.pause()
	
	HUD.hide()
	
	$Camera3D.current = true


func _physics_process(delta):
	handle_camera_movement()
	






func handle_camera_movement():
	var input_dir = get_input_direction()
	var direction = (transform.basis * input_dir).normalized()
	direction = direction.rotated(Vector3.DOWN, deg_to_rad(-45))
	
	$Camera3D.global_position += direction



func get_input_direction() -> Vector3:
	var dir = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		dir.z -= 1
	if Input.is_action_pressed("move_backward"):
		dir.z += 1
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1
	return dir


func _on_exit_button_pressed():
	var player = get_tree().get_first_node_in_group("player")
	HUD.show()
	player.unpause()
	queue_free()
