extends Node

var companies: Array[Company] = []

var company_textures: Dictionary

var companies_selling_shares = []

# 0 = Food 
# 1 = Utility
# 2 = Gadget


var default_prices = {
	0: 5,
	1: 10,
	2: 100
}

# Autoloaded

# This script keeps track of companies

# Updated on client also but server has authoritative "final say version"



func add_company(company: Company):
	companies.append(company)

func change_company_value(company_id,amount):
	companies[company_id].value += amount


@rpc("any_peer","reliable","call_local")
func request_buy_shares(company_id,buying_amount,buyer_id):
	var hud = get_tree().get_first_node_in_group("hud")
	var company = companies[company_id]
	
	var market_owned_shares = company.shareholders[0]
	
	if not company.shareholders.has(0):
		hud.rpc_id(buyer_id,"add_info", "Market doesn't have stock")
		return
	
	if buying_amount > market_owned_shares:
		hud.rpc_id(buyer_id,"add_info", "Shares not bought. Numbers don't match")
		return
	
	var share_value = get_share_value(company_id)
	var bought_shares_value = buying_amount * share_value
	
	
	
	var buyer_old_money = PossessionManager.player_money[buyer_id]
	var buyer_new_money = buyer_old_money - bought_shares_value
	
	if buyer_new_money < 0:
		hud.rpc_id(buyer_id,"add_info", "Shares not bought. Not enough money")
		return
	
	var buyer_old_shares = 0
	
	if company.shareholders.has(buyer_id):
		buyer_old_shares = company.shareholders[buyer_id]
	
	var buyer_new_shares = buyer_old_shares + buying_amount
	
	var market_old_shares = company.shareholders[0]
	var market_new_shares = market_old_shares - buying_amount
	
	if market_new_shares < 1:
		remove_operator_from_owners.rpc(0,company_id)
	
	
	confirm_buy_shares.rpc(company_id,buyer_id,buyer_new_money,buyer_new_shares,market_new_shares)
	


@rpc("any_peer","reliable","call_local")
func confirm_buy_shares(company_id,buyer_id,buyer_new_money,buyer_new_shares,market_shares):
	var company = companies[company_id]
	
	
	if market_shares:
		company.shareholders[0] = market_shares
	
	company.shareholders[buyer_id] = buyer_new_shares
	
	PossessionManager.player_money[buyer_id] = buyer_new_money
	
	
	var company_options = get_tree().get_first_node_in_group("company_options")
	
	var editable = false
	
	if company.owner_id == multiplayer.get_unique_id():
		editable = true
	
	
	if company_options and editable:
		company_options.update_company_panel(company_id,editable)
	
	get_tree().call_group("updatable","update_data")
	
	if multiplayer.is_server():
		check_company_owner_by_shares(company_id)
	


@rpc("any_peer","reliable","call_local")
func request_sell_shares(company_id,total_amount,seller_id):
	var hud = get_tree().get_first_node_in_group("hud")
	
	#Check if legit
	var company = companies[company_id]
	var seller_owned_share_amount = company.shareholders[seller_id]
	if total_amount > seller_owned_share_amount:
		hud.rpc_id(seller_id,"add_info", "Shares not sold. Numbers don't match")
		return
	
	var share_value = get_share_value(company_id)
	var sold_shares_value = total_amount * share_value
	
	
	
	var seller_old_money = PossessionManager.player_money[seller_id]
	var seller_new_money = seller_old_money + sold_shares_value
	
	var seller_old_shares = company.shareholders[seller_id]
	var seller_new_shares = seller_old_shares - total_amount
	
	var market_shares
	
	if seller_new_shares:
		remove_operator_from_owners(seller_id,company_id)
	
	
	if company.shareholders.has(0):
		market_shares = company.shareholders[0] + total_amount
	else:
		market_shares = total_amount
	
	confirm_sell_shares.rpc(company_id,seller_id,seller_new_money,seller_new_shares,market_shares)




@rpc("any_peer","reliable","call_local")
func confirm_sell_shares(company_id,seller_id,seller_new_money,seller_new_shares,market_shares):
	var company = companies[company_id]
	
	
	if market_shares:
		company.shareholders[0] = market_shares
	
	company.shareholders[seller_id] = seller_new_shares
	
	PossessionManager.player_money[seller_id] = seller_new_money
	
	var company_options = get_tree().get_first_node_in_group("company_options")
	
	var editable = false
	
	if company.owner_id == multiplayer.get_unique_id():
		editable = true
	
	if company_options and editable:
		company_options.update_company_panel(company_id,true)
	
	get_tree().call_group("updatable","update_data")
	
	if multiplayer.is_server():
		check_company_owner_by_shares(company_id)
	
	if multiplayer.is_server():
		if seller_new_shares < 1:
			remove_operator_from_owners.rpc(seller_id,company_id)
	


@rpc("any_peer","reliable","call_local")
func remove_operator_from_owners(seller_id,company_id):
	var company = companies[company_id]
	company.shareholders.erase(seller_id)
	
	get_tree().call_group("updatable","update_data")


@rpc("any_peer","reliable","call_local")
func change_company_owner_for_clients(company_id,new_owner_id):
	var company = companies[company_id]
	
	print("New owner is: " + str(new_owner_id))
	
	company.owner_id = new_owner_id
	
	print("New owner is by data: " + str(company.owner_id))
	
	get_tree().call_group("updatable","update_data")





@rpc("any_peer","reliable","call_local")
func request_add_company_texture(company_id,data_packet):
	var sender_id = multiplayer.get_remote_sender_id()
	var company = companies[company_id]
	
	
	if sender_id == company.owner_id:
		confirm_add_company_texture.rpc(company_id,data_packet)
	else:
		var hud = get_tree().get_first_node_in_group("hud")
		hud.rpc_id(sender_id,"add_info" , "Not owner of the company!")


@rpc("authority","reliable","call_local")
func confirm_add_company_texture(company_id,data_packet):
	
	
	var image = Image.create_from_data(256,256,false,Image.Format.FORMAT_RGBH,data_packet)
	
	var texture = ImageTexture.create_from_image(image)
	
	
	
	company_textures[company_id] = texture
	
	
	get_tree().call_group("updatable","update_data")


@rpc("reliable", "any_peer", "call_local")
func request_create_company(exported_name,type):
	var sender_id = multiplayer.get_remote_sender_id()
	
	
	var player_money = PossessionManager.player_money[sender_id]
	
	
	
	
	if CompanyManager.is_name_taken(exported_name):
		client_company_create_failed.rpc_id(sender_id,"Name already in use")
		return

	if not (type in Company.CompanyType.values()):
		client_company_create_failed.rpc_id(sender_id,"Invalid company type")
		return
	
	if player_money < 500:
		client_company_create_failed.rpc_id(sender_id,"Not enough money")
		return
	
	
	var new_amount = player_money - 500
	
	PossessionManager.set_player_money.rpc(sender_id,new_amount)
	
	# Passed checks – create company
	
	
	var new_company = Company.new()
	new_company.name = exported_name
	new_company.id = CompanyManager.companies.size()
	new_company.value = 250
	new_company.type = type
	new_company.money = 0.0
	new_company.owner_id = sender_id
	new_company.shareholders[sender_id] = 100
	
	client_company_created.rpc(new_company.to_dict())
	


@rpc("any_peer","reliable","call_local")
func client_company_created(data: Dictionary):
	var company = Company.new()
	company.from_dict(data)
	add_company(company)
	
	get_tree().call_group("updatable","update_data")
	

@rpc("any_peer","call_local")
func client_company_create_failed(reason: String):
	var hud = get_tree().get_first_node_in_group("hud")
	hud.add_info(reason)



# -------------------- UTILITY FUNCTIONS -----------------------




func is_stock_owner(player_id, company_id) -> bool:
	var company = companies.get(company_id)
	if company == null:
		return false
	
	return company.owner_id == player_id or company.shareholders.has(player_id)



func check_company_owner_by_shares(company_id):
	var biggest_share_owner = get_biggest_share_owner_id(company_id)
	
	var company = companies[company_id]
	
	
	if str(company.owner_id) != str(biggest_share_owner):
		change_company_owner_for_clients.rpc(company_id,biggest_share_owner)
	





func get_biggest_share_owner_id(company_id):
	var company = companies[company_id]
	var biggest_owner = null
	var biggest_share = -1
	
	for shareholder_id in company.shareholders.keys():
		if shareholder_id == 0:
			continue
	
		var share_amount = company.shareholders[shareholder_id]
		if share_amount > biggest_share:
			biggest_share = share_amount
			biggest_owner = shareholder_id
	
	if biggest_share < 1:
		biggest_owner = 0
	
	return biggest_owner



func get_total_shares(company_id) -> int:
	var company = companies[company_id]
	var total_shares: int = 0
	for holder in company.shareholders:
		total_shares += company.shareholders[holder]
	
	return total_shares

func get_owned_shares(player_id,company_id) -> int:
	var company = companies[company_id]
	var owned_shares: int = 0
	
	if company.shareholders.has(player_id):
		owned_shares += company.shareholders[player_id]
	
	return owned_shares

func get_share_value(company_id):
	var company = companies[company_id]
	
	var company_money = company.money
	
	var share_value = snappedf((company.value + company_money)/CompanyManager.get_total_shares(company_id),0.01)
	
	return share_value

func get_companies_by_owner(owner_id: int) -> Array:
	return companies.filter(func(p): return p.owner_id == owner_id)

func get_companies_with_owned_shares(player_id):
	return companies.filter(func(c): return c.shareholders.has(player_id) and c.owner_id != player_id)

func calculate_influence():
	pass

func to_save_format() -> Array:
	return companies.map(func(c): return c.to_dict())

func load_from_data(data: Array):
	companies.clear()
	for d in data:
		var c = Company.new()
		c.from_dict(d)
		companies.append(c)

func is_name_taken(exported_name: String) -> bool:
	
	for company in companies:
		if company.name.to_lower() == exported_name.to_lower():
			return true
	return false
