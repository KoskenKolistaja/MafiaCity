extends Node3D
class_name FurniturePlacer

var building_node

var building_id: int
var building_size: Vector3
var speed := 0.1

var half_size := 9
var grid_manager

# Visual prefabs
var visuals := {
	"checkout": preload("res://Entities/BuildingObjects/BuildingVisuals/checkout_visual.tscn"),
	"shelf": preload("res://Entities/BuildingObjects/BuildingVisuals/shelf_visual.tscn"),
	"computer": preload("res://Entities/BuildingObjects/BuildingVisuals/computer_visual.tscn"),
}

var selected_item_name
var current_snapped_position = Vector3i.ZERO

func _ready():
	set_item_metadata()
	
	building_node = BuildingManager.get_building(building_id)
	
	# Hide walls and pause player for placement mode
	if get_parent().has_method("hide_walls"):
		get_parent().hide_walls()

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.pause()

	$Camera3D.current = true

	# Pull building data from BuildingManager
	var building_data = BuildingManager.buildings[building_id]
	if building_data:
		half_size = building_data.building_size.x
		self.global_position = building_node.global_position
		grid_manager = building_node.get_grid_manager()

	# Disable placement if building isn't owned
	if building_data and building_data.company_id == null:
		$Control/ItemList.set_item_disabled(0, true)
		$Control/ItemList.set_item_disabled(1, true)
	else:
		$Control/ItemList.set_item_disabled(0, false)
		$Control/ItemList.set_item_disabled(1, false)

	HUD.hide_sidebar()

func set_item_metadata():
	$Control/ItemList.set_item_metadata(0, "checkout")
	$Control/ItemList.set_item_metadata(1, "shelf")
	$Control/ItemList.set_item_metadata(2, "computer")

func _physics_process(delta):
	handle_camera_movement()
	handle_cursor()

	if Input.is_action_just_pressed("mouse1") and selected_item_name:
		attempt_placement()
	elif Input.is_action_just_pressed("mouse2"):
		unselect_item()

	if Input.is_action_just_pressed("rotate"):
		$Cursor.rotation_degrees.y += 90

func attempt_placement():
	if current_snapped_position == null:
		print("Returned — position not valid")
		return

	var item_rotation = $Cursor.global_rotation_degrees

	# Send request to server via BuildingManager
	BuildingManager.rpc_id(1, "request_place_fixture",
		building_id,
		selected_item_name,
		current_snapped_position,
		item_rotation
	)
	unselect_item()

func handle_camera_movement():
	var input_dir = get_input_direction()
	var direction = (transform.basis * input_dir).normalized()
	direction = direction.rotated(Vector3.DOWN, deg_to_rad(-45))

	var center = global_position
	var proposed_position = global_position + direction * speed

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
	var cam = $Camera3D
	var mouse_pos = get_viewport().get_mouse_position()

	var from = cam.project_ray_origin(mouse_pos)
	var to = from + cam.project_ray_normal(mouse_pos) * max_distance

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1 << 3
	var result = space_state.intersect_ray(query)

	return result.position if result else null

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
	if player:
		player.unpause()
		player.set_current_camera()

	if get_parent().has_method("show_walls"):
		get_parent().show_walls()

	HUD.show_sidebar()
	queue_free()

func _on_item_list_item_selected(index):
	select_item(index)

func select_item(index):
	selected_item_name = $Control/ItemList.get_item_metadata(index)
	var item_instance = visuals[selected_item_name].instantiate()

	# Clear existing preview
	for item in $Cursor.get_children():
		item.queue_free()

	$Cursor.add_child(item_instance)

func unselect_item():
	selected_item_name = null
	for item in $Cursor.get_children():
		item.queue_free()
