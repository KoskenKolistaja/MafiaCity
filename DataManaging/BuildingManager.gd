extends Node
# Autoload as "BuildingManager"

const BuildingDataRes := preload("res://DataManaging/building_data.gd")
const FixtureDataRes := preload("res://DataManaging/fixture_data.gd")

signal building_synced(building_id: int, data: Dictionary) # Emitted on clients

var next_building_id = 1


# Server-authoritative cache: { id: BuildingData }
var server_buildings: Dictionary = {}
# Client cache: { id: Dictionary }
var client_buildings: Dictionary = {}

func is_server() -> bool:
	return multiplayer.is_server()

# --- Creation / IDs ---

func _physics_process(delta):
	Debug.text = str(client_buildings)


@rpc("any_peer", "reliable")
func request_buy_building(building_id: int, company_id= null, company_paying: bool = false) -> void:
	# 1. Only the server can process purchases
	if not multiplayer.is_server():
		return

	var buyer_id = multiplayer.get_remote_sender_id()

	# 2. Get building data
	var building_data = server_buildings.get(building_id, null)
	if building_data == null:
		rpc_id(buyer_id, "notify_purchase_failed", "Building not found")
		return

	# 3. Check if building is already owned
	if building_data.get("owner_id") != null:
		rpc_id(buyer_id, "notify_purchase_failed", "Building already owned")
		return

	# 4. Get price
	var price = building_data.get("value", 0)

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
		building_data["owner_id"] = company_id
		building_data["owned_by_company"] = true

	else:
		# Personal purchase
		if PossessionManager.player_money[buyer_id] < price:
			rpc_id(buyer_id, "notify_purchase_failed", "Insufficient funds")
			return
		PossessionManager.player_money[buyer_id] -= price
		building_data["owner_id"] = buyer_id
		building_data["owned_by_company"] = false

	# 6. Sync changes to all clients
	BuildingManager.buildings[building_id] = building_data
	rpc("sync_building_data", building_id, building_data)

	# 7. Notify buyer of success
	rpc_id(buyer_id, "notify_purchase_success", building_id)


@rpc("any_peer","reliable","call_local")
func request_allocate_building(initial_data: Dictionary) -> void:
	# Only server should allocate
	if not is_server():
		return
	var bd := BuildingDataRes.new()
	bd.from_dict(initial_data)
	if bd.id < 0:
		bd.id = BuildingManager.get_free_building_id()
	server_buildings[bd.id] = bd
	# Notify the caller (and optionally all peers) with full sync
	rpc("client_sync_building", bd.id, bd.to_dict())

# --- Read access (clients can request a fresh copy) ---

@rpc("any_peer","reliable","call_local")
func request_sync(building_id: int) -> void:
	if not is_server(): return
	var bd: BuildingData = server_buildings.get(building_id)
	if bd:
		rpc("client_sync_building", building_id, bd.to_dict())

@rpc("any_peer","reliable","call_local")
func client_sync_building(building_id: int, data: Dictionary) -> void:
	client_buildings[building_id] = data
	emit_signal("building_synced", building_id, data)

func get_client_building(building_id: int) -> Dictionary:
	return client_buildings.get(building_id, {})

# --- Mutations (server only) ---

@rpc("any_peer","reliable","call_local")
func request_place_fixture(building_id: int, fixture_type: String, pos: Vector2i, rot_degrees: Vector3) -> void:
	if not is_server(): return
	var sender_id := multiplayer.get_remote_sender_id()
	var bd: BuildingData = server_buildings.get(building_id)
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
	fd.position = pos
	fd.rotation_degrees = rot_degrees
	bd.fixtures[pos] = fd

	# Broadcast to all
	rpc("client_sync_building", building_id, bd.to_dict())

@rpc("any_peer","reliable","call_local")
func request_set_owner(building_id: int, new_owner_peer_id: int) -> void:
	if not is_server(): return
	var bd: BuildingData = server_buildings.get(building_id)
	if not bd: return
	bd.owner_id = new_owner_peer_id
	rpc("client_sync_building", building_id, bd.to_dict())

@rpc("any_peer","reliable","call_local")
func request_set_company(building_id: int, company_id: int) -> void:
	if not is_server(): return
	var bd: BuildingData = server_buildings.get(building_id)
	if not bd: return
	bd.company_id = company_id
	rpc("client_sync_building", building_id, bd.to_dict())


func get_free_building_id():
	var id = next_building_id
	next_building_id += 1
	return id
