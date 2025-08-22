extends Node3D


var apartment


var target_position 

var target_shelf



func _ready():
	if multiplayer.is_server():
		$SyncTimer.start()
		await get_tree().create_timer(0.1).timeout
		force_position.rpc(self.global_position)
		$NavigationAgent3D.target_position = target_shelf.global_position
		update_target.rpc($NavigationAgent3D.get_next_path_position())
	else:
		hide()

func _physics_process(delta):
	if multiplayer.is_server():
		server_movement()
	else:
		client_movement()
	


func server_movement():
	if not $NavigationAgent3D.is_navigation_finished():
		
		var next_position = $NavigationAgent3D.get_next_path_position()
		move_to_target(next_position)
		$AnimationPlayer.play("walk")
	else:
		$AnimationPlayer.play("idle")


func client_movement():
	if target_position:
		move_to_target(target_position)
		$AnimationPlayer.play("walk")
	else:
		$AnimationPlayer.play("idle")





@rpc("authority","reliable")
func force_position(exported_position : Vector3) -> void:
	self.global_position = exported_position
	print("Position forced for: " + str(multiplayer.get_unique_id()))
	show()

@rpc("any_peer","reliable")
func update_target(exported_position : Vector3) -> void:
	target_position = exported_position
	print("Target updated for: " + str(multiplayer.get_unique_id()))

func item_picked(string):
	update_item.rpc("product")

@rpc("authority","reliable","call_local")
func update_item(string):
	var item = ItemData.products[string]
	var item_instance = item.instantiate()
	
	var items = $Visual/HandItem.get_children()
	
	for hand_item in items:
		hand_item.queue_free()
	
	$Visual/HandItem.add_child(item_instance)






func move_to_target(target_pos):
	
	var direction = (target_pos - self.global_position).normalized()
	
	global_position += direction * 0.03
	
	rotate_towards_position(target_pos)
	


func rotate_towards_position(target_pos):
	
	if not target_pos:
		return
	
	var direction = (target_pos - $Visual.global_transform.origin).normalized()

	# Optional: if you want to keep player upright (no tilting up/down)
	direction.y = 0
	direction = direction.normalized()

	# Create a new basis facing the direction vector
	var new_basis = Basis().looking_at(direction, Vector3.UP)

	# Apply new rotation to player
	$Visual.global_transform.basis = new_basis


func _on_navigation_agent_3d_target_reached():
	target_position = null


func _on_sync_timer_timeout():
	force_position.rpc(self.global_position)


var is_updating = false

func _on_navigation_agent_3d_waypoint_reached(details):
	if multiplayer.is_server() and not is_updating:
		is_updating = true
		update_target.rpc($NavigationAgent3D.get_next_path_position())
		is_updating = false
