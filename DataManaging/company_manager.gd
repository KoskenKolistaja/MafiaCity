extends Node

var companies: Array[Company] = []

var company_textures: Dictionary

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



@rpc("any_peer","reliable")
func request_add_company_texture(company_id,data_packet):
	confirm_add_company_texture.rpc(company_id,data_packet)

@rpc("authority","reliable","call_local")
func confirm_add_company_texture(company_id,data_packet):
	
	
	var image = Image.create_from_data(256,256,false,Image.Format.FORMAT_RGBH,data_packet)
	
	var texture = ImageTexture.create_from_image(image)
	
	
	
	company_textures[company_id] = texture


@rpc("reliable", "any_peer", "call_local")
func request_create_company(exported_name,type):
	
	print("Requesting company creation!")
	
	var sender_id = multiplayer.get_remote_sender_id()
	
	if CompanyManager.is_name_taken(exported_name):
		client_company_create_failed.rpc_id(sender_id,"Name already in use")
		return

	if not (type in Company.CompanyType.values()):
		client_company_create_failed.rpc_id(sender_id,"Invalid company type")
		return
	
	print("Got trough checks!")
	
	# Passed checks – create company
	
	
	var new_company = Company.new()
	new_company.name = exported_name
	new_company.id = CompanyManager.companies.size()
	new_company.value = 0
	new_company.type = type
	new_company.owner_id = sender_id
	new_company.shareholders[sender_id] = 100
	
	add_company(new_company)
	client_company_created.rpc(new_company.to_dict())
	
	get_tree().call_group("updatable","update_data")


@rpc("any_peer","reliable")
func client_company_created(data: Dictionary):
	var company = Company.new()
	company.from_dict(data)
	CompanyManager.add_company(company)
	
	get_tree().call_group("updatable","update_data")
	

@rpc("any_peer","call_local")
func client_company_create_failed(reason: String):
	pass



# -------------------- UTILITY FUNCTIONS -----------------------

func get_total_shares(company_id):
	var company = companies[company_id]
	var total_shares = 0
	for holder in company.shareholders:
		total_shares += company.shareholders[holder]
	
	return total_shares

func get_owned_shares(player_id,company_id):
	var company = companies[company_id]
	var owned_shares = 0
	
	owned_shares += company.shareholders[player_id]
	
	return owned_shares

func get_companies_by_owner(owner_id: int) -> Array:
	return companies.filter(func(p): return p.owner_id == owner_id)

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
