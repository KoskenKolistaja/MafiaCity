extends Node3D

var building_id
var building_size
var speed = 0.1

var half_size = 9


func _ready():
	var player = get_tree().get_first_node_in_group("player")
	
	player.pause()
	
	HUD.hide()
	
	$Camera3D.current = true
	
	var building_dictionary = PossessionManager.buildings[building_id]
	var building = building_dictionary["building"]
	
	print(building.global_position)
	
	half_size = building.building_size.x * 1.5
	
	self.global_position = building.global_position

func _physics_process(delta):
	handle_camera_movement()







func handle_camera_movement():
	var input_dir = get_input_direction()
	var direction = (transform.basis * input_dir).normalized()
	direction = direction.rotated(Vector3.DOWN, deg_to_rad(-45))
	
	var building_dictionary = PossessionManager.buildings[building_id]
	var building = building_dictionary["building"]
	
	var move_input = direction
	
	var center = building.global_position
	
	var proposed_position = global_position + move_input * speed

	proposed_position.x = clamp(proposed_position.x, center.x - half_size, center.x + half_size)
	proposed_position.z = clamp(proposed_position.z, center.z - half_size, center.z + half_size)

	global_position = proposed_position
	
	




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
