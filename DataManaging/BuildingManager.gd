extends Node
# Autoload as "BuildingManager"

const BuildingDataRes := preload("res://DataManaging/building_data.gd")
const FixtureDataRes := preload("res://DataManaging/fixture_data.gd")

signal building_synced(building_id: int, data: Dictionary) # Emitted on clients

var next_building_id = 4
var next_fixture_id = 1


var buildings: Dictionary = {}
var building_presenters := {}     # Maps building_id -> Node3D (the actual scene node)

func is_server() -> bool:
	return multiplayer.is_server()

# --- Creation / IDs ---




@rpc("any_peer", "reliable","call_local")
func request_buy_building(building_id: int, company_id= null, company_paying: bool = false) -> void:
	# 1. Only the server can process purchases
	if not multiplayer.is_server():
		return

	var buyer_id = multiplayer.get_remote_sender_id()

	# 2. Get building data
	var building_data = buildings[building_id]
	if building_data == null:
		rpc_id(buyer_id, "notify_purchase_failed", "Building not found")
		return

	# 3. Check if building is already owned
	if building_data.get("owner_id") > 0:
		rpc_id(buyer_id, "notify_purchase_failed", "Building already owned")
		return

	# 4. Get price
	var price = building_data.get("value")

	# 5. Handle payment source
	if company_id != null:
		var company = CompanyManager.companies[company_id]
		if company == null:
			rpc_id(buyer_id, "notify_purchase_failed", "Company not found")
			return

		if company_paying:
			# Company pays
			if company.money < price:
				rpc_id(buyer_id, "notify_purchase_failed", "Company has insufficient funds")
				return
			company.money -= price
		else:
			# Player pays for company asset
			if PossessionManager.player_money[buyer_id] < price:
				rpc_id(buyer_id, "notify_purchase_failed", "Insufficient personal funds")
				return
			PossessionManager.player_money[buyer_id] -= price

		# Assign ownership to the company
		building_data["owner_id"] = buyer_id
		building_data["company_id"] = company_id
	
	else:
		# Personal purchase
		if PossessionManager.player_money[buyer_id] < price:
			rpc_id(buyer_id, "notify_purchase_failed", "Insufficient funds")
			return
		PossessionManager.player_money[buyer_id] -= price
		building_data["owner_id"] = buyer_id
	
	# 6. Sync changes to all clients
	rpc("sync_building_data", building_id, building_data)
	
	
	# 7. Notify buyer of success
	rpc_id(buyer_id, "notify_purchase_success")

@rpc("any_peer","reliable","call_local")
func notify_purchase_failed(reason:String):
	HUD.add_info("Purchase failed! " + reason)

@rpc("any_peer","reliable","call_local")
func notify_purchase_success():
	HUD.add_info("Building purchased!")
	HUD.update_data()

@rpc("any_peer","reliable","call_local")
func sync_building_data(building_id : int, data : Dictionary) -> void:
	buildings[building_id] = data
	emit_signal("building_synced", building_id, data)
	get_tree().call_group("updatable","update_data")

@rpc("any_peer","reliable","call_local")
func request_allocate_building(initial_data: Dictionary) -> void:
	# Only server should allocate
	if not is_server():
		return
	var bd := BuildingDataRes.new()
	bd.from_dict(initial_data)
	if bd.id < 0:
		bd.id = get_free_building_id()
	buildings[bd.id] = bd
	# Notify the caller (and optionally all peers) with full sync
	rpc("sync_building_data", bd.id, bd.to_dict())
	
	

# --- Read access (clients can request a fresh copy) ---

@rpc("any_peer","reliable","call_local")
func request_sync(building_id: int) -> void:
	if not is_server(): return
	var bd: BuildingData = buildings.get(building_id)
	if bd:
		rpc("sync_building_data", building_id, bd.to_dict())


func get_building(building_id):
	var building_list = get_tree().get_nodes_in_group("building")
	
	for item in building_list:
		if item.building_id == building_id:
			return item
	
	
	push_error("Tried to access building with invalid id! get_building()")
	return null

func get_fixture(fixture_id):
	var fixture_list = get_tree().get_nodes_in_group("fixture")
	
	for item in fixture_list:
		if item.id == fixture_id:
			return item
	
	
	push_error("Tried to access fixture with invalid id! get_fixture()")
	return null



func get_client_building(building_id: int) -> Dictionary:
	return buildings.get(building_id , {})

# --- Mutations (server only) ---


@rpc("any_peer","reliable","call_local")
func request_fill_shelf(fixture_id):
	var sender_id = multiplayer.get_remote_sender_id()
	
	var shelf = get_fixture(fixture_id)
	
	var array: Array = shelf.shelf_positions.duplicate()
	
	var index = array.find(false)
	
	array[index] = true
	
	if index != -1:
		confirm_fill_shelf.rpc(fixture_id,array)
	else:
		HUD.rpc_id(sender_id,"add_info","Shelf is full!")

@rpc("authority","reliable","call_local")
func confirm_fill_shelf(fixture_id : int, array : Array):
	var shelf = get_fixture(fixture_id)
	shelf.update_array(array)


@rpc("any_peer","reliable","call_local")
func request_place_fixture(building_id: int, fixture_type: String, pos: Vector2i, rot_degrees: Vector3) -> void:
	if not is_server(): return
	var sender_id := multiplayer.get_remote_sender_id()
	var bd = BuildingDataRes.new()
	bd.from_dict(buildings[building_id])
	if not bd: return

	# Validation: ownership / permissions (example: only owner can place)
	if bd.owner_id != sender_id:
		# You can swap this for a HUD.rpc_id if you prefer
		return

	# Validation: occupancy
	if bd.fixtures.has(pos):
		return

	# Validation: money
	var price = ItemData.fixture_prices.get(fixture_type, null)
	if price == null: return
	var money = PossessionManager.player_money.get(sender_id, 0.0)
	if money < price: return

	# Charge player
	PossessionManager.rpc("set_player_money", sender_id, money - price)

	# Commit state
	var fd := FixtureDataRes.new()
	fd.type = fixture_type
	fd.id = get_free_fixture_id()
	fd.position = pos
	fd.rotation_degrees = rot_degrees
	bd.fixtures[pos] = fd

	# Broadcast to all
	rpc("sync_building_data", building_id, bd.to_dict())

@rpc("any_peer","reliable","call_local")
func request_set_owner(building_id: int, new_owner_peer_id: int) -> void:
	if not is_server(): return
	var bd: BuildingData = buildings.get(building_id)
	if not bd: return
	bd.owner_id = new_owner_peer_id
	rpc("sync_building_data", building_id, bd.to_dict())

@rpc("any_peer","reliable","call_local")
func request_set_company(building_id: int, company_id: int) -> void:
	if not is_server(): return
	var bd: BuildingData = buildings.get(building_id)
	if not bd: return
	bd.company_id = company_id
	rpc("sync_building_data", building_id, bd.to_dict())


func get_free_fixture_id():
	var id = next_fixture_id
	next_fixture_id += 1
	return id

func get_free_building_id():
	var id = next_building_id
	next_building_id += 1
	return id

func register_building(building_id: int, node: Node3D):
	building_presenters[building_id] = node

func get_building_presenter(building_id: int) -> Node3D:
	return building_presenters.get(building_id, null)

func unregister_building(building_id: int):
	building_presenters.erase(building_id)
