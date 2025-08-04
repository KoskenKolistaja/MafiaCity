extends CharacterBody3D


var player_id = -1

@export var move_speed: float = 5.0
@export var jump_velocity: float = 6.0
@export var gravity: float = 9.8





func _ready():
	set_multiplayer_authority(player_id)
	
	if is_multiplayer_authority():
		$Camera3D.current = true



func _physics_process(delta):
	if is_multiplayer_authority():
		var input_dir = get_input_direction()
		var direction = (transform.basis * input_dir).normalized()
		
		direction = direction.rotated(Vector3.DOWN,deg_to_rad(-45))
		
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
