extends Node3D

var building_id
var building_size
var speed = 0.1

var half_size = 9

var grid_manager

var checkout = preload("res://Entities/BuildingObjects/BuildingVisuals/checkout_visual.tscn")
var shelf = preload("res://Entities/BuildingObjects/BuildingVisuals/shelf_visual.tscn")

var visuals = {
	"checkout" : checkout,
	"shelf" : shelf
}

var string
var current_snapped_position = null

func _ready():
	
	grid_manager = get_parent().get_grid_manager()
	
	set_item_metadata()
	
	get_parent().hide_walls()
	
	var player = get_tree().get_first_node_in_group("player")
	player.pause()
	
	$Camera3D.current = true
	
	var building_dictionary = PossessionManager.buildings[building_id]
	var building = building_dictionary["building"]
	half_size = building.building_size.x * 1.5
	self.global_position = building.global_position


func set_item_metadata():
	$Control/ItemList.set_item_metadata(0,"checkout")
	$Control/ItemList.set_item_metadata(1,"shelf")

func _physics_process(delta):
	handle_camera_movement()
	handle_cursor()
	
	
	if Input.is_action_just_pressed("mouse1"):
		attempt_placement()
	if Input.is_action_just_pressed("mouse2"):
		unselect_item()
	
	if Input.is_action_just_pressed("rotate"):
		$Cursor.rotation_degrees.y += 90



func attempt_placement():
	if not current_snapped_position:
		return
	unselect_item()
	
	var item_rotation = $Cursor.global_rotation_degrees
	
	get_parent().rpc_id(1,"request_placement",string,current_snapped_position,item_rotation)


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
	
	


func handle_cursor():
	var projected_position = get_projected_mouse_position()
	if projected_position == null:
		return
	var snapped_position = grid_manager.world_to_grid(projected_position)
	var snapped_to_world = grid_manager.grid_to_world(snapped_position)
	
	
	
	if grid_manager.is_within_bounds(snapped_position):
		$Cursor.global_position = snapped_to_world
		current_snapped_position = snapped_position
	else:
		$Cursor.global_position = projected_position
		current_snapped_position = null
	





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


func _on_exit_button_pressed():
	var player = get_tree().get_first_node_in_group("player")
	player.unpause()
	queue_free()
	get_parent().show_walls()

func _on_item_list_item_selected(index):
	select_item(index)

func select_item(index):
	string = $Control/ItemList.get_item_metadata(index)
	var item_instance = visuals[string].instantiate()
	var cursor_children = $Cursor.get_children()
	for item in cursor_children:
		item.queue_free()
	
	$Cursor.add_child(item_instance)

func unselect_item():
	var cursor_children = $Cursor.get_children()
	for item in cursor_children:
		item.queue_free()
