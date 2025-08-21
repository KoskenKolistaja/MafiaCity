extends Node3D


var apartment


var target_position 

var target_shelf



func _ready():
	if multiplayer.is_server():
		$SyncTimer.start()
		force_position.rpc(self.global_position)
		update_target.rpc(target_shelf.global_position)

func _physics_process(delta):
	if not $NavigationAgent3D.is_navigation_finished():
		move_to_target()
		$AnimationPlayer.play("walk")
	else:
		$AnimationPlayer.play("idle")

@rpc("authority","reliable")
func force_position(exported_position : Vector3) -> void:
	self.global_position = exported_position
	print("Position forced")

@rpc("authority","call_local")
func update_target(exported_position : Vector3) -> void:
	$NavigationAgent3D.target_position = exported_position


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






func move_to_target():
	var next_position = $NavigationAgent3D.get_next_path_position()
	
	var direction = (next_position - self.global_position).normalized()
	
	global_position += direction * 0.03
	
	rotate_towards_position(next_position)
	


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
