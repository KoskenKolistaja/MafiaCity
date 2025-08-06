extends CharacterBody3D


var player_id = -1
	#set(val):
		#player_id = val
		#set_multiplayer_authority(player_id)

@export var move_speed: float = 5.0
@export var jump_velocity: float = 2.0
@export var gravity: float = 9.8



@onready var state_machine = $AnimationTree.get("parameters/playback")

var anim_state

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	player_id = name.to_int()
	$Visual/InteractionRay.set_multiplayer_authority(name.to_int())
	

func _ready() -> void:
	if is_multiplayer_authority():
		$Camera3D.current = true
		print("Camera current")
	else:
		remove_from_group("player")

#func _on_ready():
	#set_multiplayer_authority(player_id)


func _physics_process(delta):
	if is_multiplayer_authority():
		handle_movement(delta)
		




func handle_movement(delta):
	
	if anim_state != state_machine.get_current_node():
		update_animation_for_peers.rpc(state_machine.get_current_node())
	
	anim_state = state_machine.get_current_node()
	
	$Camera3D.global_position = self.global_position + Vector3(10,15,10)
	
	var input_dir = get_input_direction()
	var direction = (transform.basis * input_dir).normalized()
	
	direction = direction.rotated(Vector3.DOWN,deg_to_rad(-45))
	
	if direction.length() > 0.1:
		state_machine.travel("walk")
		$Visual.rotation_degrees.y = rad_to_deg(direction.signed_angle_to(-transform.basis.z,Vector3.DOWN))
	else:
		state_machine.travel("idle")
	
	# Horizontal movement
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	
	
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		# Jumping
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	# Apply movement
	move_and_slide()


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
