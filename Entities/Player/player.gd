extends CharacterBody3D


var player_id = -1
	#set(val):
		#player_id = val
		#set_multiplayer_authority(player_id)

@export var move_speed: float = 5.0
@export var jump_velocity: float = 2.0
@export var gravity: float = 9.8

var paused = false

@onready var state_machine = $AnimationTree.get("parameters/playback")

var smoothing_speed = 7

var anim_state

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	player_id = name.to_int()
	$Visual/InteractionRay.set_multiplayer_authority(name.to_int())
	$PhantomPosition.set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if is_multiplayer_authority():
		$Camera3D.current = true
	else:
		remove_from_group("player")

#func _on_ready():
	#set_multiplayer_authority(player_id)

func pause():
	paused = true
	$Visual/InteractionRay.paused = true

func unpause():
	paused = false
	$Visual/InteractionRay.paused = false


func _process(delta):
	if Input.is_action_just_pressed("open_debug"):
		if Debug.visible:
			$PhantomPosition.hide()
		else:
			$PhantomPosition.show()


func _physics_process(delta):
	if is_multiplayer_authority() and not paused:
		handle_movement(delta)
		handle_phantom_position()
		move_and_slide()
		rotate_towards_mouse()
	else:
		client_side_movement(delta)
		client_side_rotation()
	


func rotate_towards_mouse():
	var target_pos = get_projected_mouse_position()
	
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
	$PhantomPosition.global_transform.basis = new_basis



func client_side_rotation():
	# Get the current and target global transforms
	var current_transform = $Visual.global_transform
	var target_transform = $PhantomPosition.global_transform
	
	$Visual.global_rotation = $Visual.global_rotation.move_toward($PhantomPosition.global_rotation,0.1)



func client_side_movement(delta):
	global_position = global_position.lerp($PhantomPosition.global_position, delta * smoothing_speed)

func handle_phantom_position():
	$PhantomPosition.global_position = self.global_position



#func handle_movement(delta):
	#
	#
	#if anim_state != state_machine.get_current_node():
		#update_animation_for_peers.rpc(state_machine.get_current_node())
	#
	#anim_state = state_machine.get_current_node()
	#
	#$Camera3D.global_position = self.global_position + Vector3(10,15,10)
	#
	#var input_dir = get_input_direction()
	#var direction = (transform.basis * input_dir).normalized()
	#
	#direction = direction.rotated(Vector3.DOWN,deg_to_rad(-45))
	#
	#if direction.length() > 0.1:
		#state_machine.travel("walk")
		#$Visual.rotation_degrees.y = rad_to_deg(direction.signed_angle_to(-transform.basis.z,Vector3.DOWN))
	#else:
		#state_machine.travel("idle")
	#
	#
	## Horizontal movement
	#velocity.x += direction.x * move_speed
	#velocity.z += direction.z * move_speed
	#
	#
	## Gravity
	#if not is_on_floor():
		#velocity.y -= gravity * delta
	#else:
		## Jumping
		#if Input.is_action_just_pressed("jump"):
			#velocity.y = jump_velocity
#
	## Apply movement




func handle_movement(delta):
	if anim_state != state_machine.get_current_node():
		update_animation_for_peers.rpc(state_machine.get_current_node())
	
	anim_state = state_machine.get_current_node()
	
	$Camera3D.global_position = global_position + Vector3(10,15,10)
	
	var input_dir = get_input_direction()
	var direction = (transform.basis * input_dir).normalized()
	direction = direction.rotated(Vector3.DOWN, deg_to_rad(-45))
	
	# Animation handling
	if direction.length() > 0.1:
		state_machine.travel("walk")
		$Visual.rotation_degrees.y = rad_to_deg(
			direction.signed_angle_to(-transform.basis.z, Vector3.DOWN)
		)
	else:
		state_machine.travel("idle")
	
	# --- Weighted movement ---
	var accel = 10.0        # units per second² when accelerating
	var decel = 8.0         # units per second² when stopping
	
	var target_vel = Vector3.ZERO
	target_vel.x = direction.x * move_speed
	target_vel.z = direction.z * move_speed
	
	# Accelerate toward target velocity
	if target_vel.length() > 0.01:
		velocity.x = lerp(velocity.x, target_vel.x, accel * delta)
		velocity.z = lerp(velocity.z, target_vel.z, accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, decel * delta)
		velocity.z = lerp(velocity.z, 0.0, decel * delta)
	
	# Gravity & jumping
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity




func get_projected_mouse_position(max_distance: float = 1000.0):
	var cam := $Camera3D  # Change to your camera node path
	var mouse_pos := get_viewport().get_mouse_position()

	var from = cam.project_ray_origin(mouse_pos)
	var to = from + cam.project_ray_normal(mouse_pos) * max_distance

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1 << 3
	var result := space_state.intersect_ray(query)

	if result:
		return result.position
	else:
		return null



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




@rpc("any_peer")
func update_animation_for_peers(anim_name):
	state_machine.travel(anim_name)
