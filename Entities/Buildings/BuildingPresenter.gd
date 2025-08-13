extends Node3D
class_name BuildingPresenter

@export var grid_manager_path: NodePath
@export var fixtures_container_path: NodePath
@export var label3d_path: NodePath
@export var logo_mesh_path: NodePath         # MeshInstance3D with material override slot 0
@export var logo_panel_surface: int = 0

var building_id: int = -1
var fixtures_nodes := {} # { Vector2i: Node3D }






func _enter_tree() -> void:
	BuildingManager.connect("building_synced", Callable(self, "_on_building_synced"), CONNECT_DEFERRED)

func _ready() -> void:
	# Immediately check if this building is already in synced data
	if BuildingManager.buildings.has(building_id):
		_on_building_synced(building_id, BuildingManager.buildings[building_id])

	# If server just created this building
	if multiplayer.is_server() and building_id < 0:
		var init := {
			"id": -1,
			"owner_id": -1,
			"company_id": -1,
			"value": 100.0,
			"building_size": Vector2i(3,3),
			"fixtures": {}
		}
		BuildingManager.rpc("request_allocate_building", init)

func _on_building_synced(id: int, data: Dictionary) -> void:
	
	print("Synced building")
	
	if data.get("owner_id") > -1:
		$BuyBlock.queue_free()
		$Door.set_multiplayer_authority(data.get("owner_id"))
	
	
	if building_id == -1:
		# First sync we receive is *our* id if we don't have one yet.
		# If you have multiple buildings in scene, set building_id via editor export.
		building_id = data.get("id", -1)
	if id != building_id:
		return
	_render_from_data(data)

func _render_from_data(data: Dictionary) -> void:
	# Label / ID
	if has_node(label3d_path):
		var label := get_node(label3d_path)
		label.text = str(data.get("id", -1))

	# Company logo (optional)
	var company_id = data.get("company_id", -1)
	_set_logo_for_company(company_id)

	# Fixtures
	var new_fixtures: Dictionary = data.get("fixtures", {})
	_sync_fixtures(new_fixtures)

func _sync_fixtures(new_fixtures: Dictionary) -> void:
	# Remove nodes that no longer exist in data
	for pos in fixtures_nodes.keys():
		if not new_fixtures.has(pos):
			var n: Node = fixtures_nodes[pos]
			if is_instance_valid(n):
				n.queue_free()
			fixtures_nodes.erase(pos)

	# Create/update nodes from data
	var grid := get_node_or_null(grid_manager_path)
	var container := get_node_or_null(fixtures_container_path)
	if not container:
		container = self

	for pos in new_fixtures.keys():
		var fd = new_fixtures[pos]
		if not fixtures_nodes.has(pos):
			var type: String = fd.get("type", "")
			var scene: PackedScene = ItemData.fixtures.get(type, null)
			if scene == null: 
				continue
			var inst := scene.instantiate()
			container.add_child(inst, true)
			fixtures_nodes[pos] = inst

		var node = fixtures_nodes[pos]
		# Position from grid
		var world_pos := Vector3.ZERO
		if grid and grid.has_method("grid_to_world"):
			world_pos = grid.grid_to_world(pos)
		node.global_position = world_pos
		node.rotation_degrees = fd.get("rotation_degrees", Vector3.ZERO)

func _set_logo_for_company(company_id: int) -> void:
	var mesh := get_node_or_null(logo_mesh_path)
	if not mesh:
		return
	var texture := _get_company_logo(company_id)
	if texture == null:
		return
	var mat = mesh.get_active_material(logo_panel_surface)
	if mat:
		mat.albedo_texture = texture
		mesh.set_surface_override_material(logo_panel_surface, mat)

func _get_company_logo(company_id: int) -> Texture2D:
	if CompanyManager.company_textures.has(company_id):
		return CompanyManager.company_textures[company_id]
	return preload("res://Assets/Textures/NoLogo.png")

func get_value() -> float:
	var data = BuildingManager.get_client_building(building_id)
	return data.get("value", 0.0)

func get_building_id() -> int:
	var data = BuildingManager.get_client_building(building_id)
	return data.get("id", 0)

# --------- Player UI hooks (client-side) ----------

func ui_request_place_fixture(fixture_type: String, snapped: Vector2i, rot_degrees: Vector3) -> void:
	# Client asks server to place fixture
	if building_id < 0: return
	BuildingManager.rpc("request_place_fixture", building_id, fixture_type, snapped, rot_degrees)

func ui_request_set_owner(new_owner_peer_id: int) -> void:
	if building_id < 0: return
	BuildingManager.rpc("request_set_owner", building_id, new_owner_peer_id)

func ui_request_set_company(company_id: int) -> void:
	if building_id < 0: return
	BuildingManager.rpc("request_set_company", building_id, company_id)

# --------- Optional: simple visibility helpers ----------

func show_walls():
	$BackWalls.show()
	$FrontWalls.show()
	$Roof.show()

func hide_walls():
	$BackWalls.hide()
	$FrontWalls.hide()
	$Roof.hide()

func fade_out():
	$AnimationPlayer.play("fade_out")

func fade_in():
	$AnimationPlayer.play("fade_in")
