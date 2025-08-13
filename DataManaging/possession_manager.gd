extends Node


var buildings = {}
var fixtures = {}

var next_building_id = 1
var next_fixture_id = 1

var player_money = {}





@rpc("any_peer","reliable","call_local")
func request_buy_building(building_id,company_id,company_paying):
	var sender_id = multiplayer.get_remote_sender_id()
	
	var building_price = buildings[building_id]["building"].value
	
	var current_player_money = PossessionManager.player_money[sender_id]
	var company_money
	
	if company_id:
		company_money = CompanyManager.companies[company_id].money
	
	
	
	if company_paying:
		if company_money >= building_price:
			pass
		else:
			rpc_id(sender_id,"reject_buy_building")
	elif not current_player_money >= building_price:
		rpc_id(sender_id,"reject_buy_building")
	
	
	if company_paying:
		company_money -= building_price
		set_company_money.rpc(company_id,company_money)
	else:
		current_player_money -= building_price
		set_player_money.rpc(sender_id,current_player_money)
	
	
	confirm_buy_building_for_clients.rpc(sender_id,building_id,company_id,building_price)



@rpc("authority","reliable","call_local")
func confirm_buy_building_for_clients(sender_id,building_id,company_id,price):
	buildings[building_id]["owner"] = sender_id
	buildings[building_id]["company_id"] = company_id
	buildings[building_id]["building"].update_owner(sender_id)
	buildings[building_id]["building"].update_company(company_id)
	
	if company_id != null:
		CompanyManager.change_company_value(company_id,price)
		
	
	
	if multiplayer.get_unique_id() == sender_id:
		HUD.add_info("Building purchased!")




@rpc("any_peer","reliable","call_local")
func set_company_money(company_id,new_amount):
	var company = CompanyManager.companies[company_id]
	company.money = new_amount

@rpc("any_peer","reliable","call_local")
func set_player_money(player_id,new_amount):
	player_money[player_id] = new_amount


@rpc("authority","reliable","call_local")
func reject_buy_building():
	var hud = get_tree().get_first_node_in_group("hud")
	
	hud.add_info("Building purchase rejected!")





func init_player_money():
	for item in PlayerData.player_dictionaries:
		player_money[item] = 2500.0
		
	
	update_money_for_clients.rpc(player_money)
	



@rpc("reliable")
func update_money_for_clients(exported_dictionary):
	player_money = exported_dictionary



func add_building(id , building , company_id = null):
	buildings[id] = {"building" : building, "owner" : null, "company_id" : company_id}

func add_fixture():
	pass




func get_free_building_id():
	var id = next_building_id
	next_building_id += 1
	return id

func get_free_fixture_id():
	var id = next_fixture_id
	next_fixture_id += 1
	return id
