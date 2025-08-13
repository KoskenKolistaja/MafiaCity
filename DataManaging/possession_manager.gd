extends Node


var player_money = {}



@rpc("any_peer","reliable","call_local")
func set_company_money(company_id,new_amount):
	var company = CompanyManager.companies[company_id]
	company.money = new_amount

@rpc("any_peer","reliable","call_local")
func set_player_money(player_id,new_amount):
	player_money[player_id] = new_amount


func init_player_money():
	for item in PlayerData.player_dictionaries:
		player_money[item] = 2500.0
		
	
	update_money_for_clients.rpc(player_money)
	



@rpc("reliable")
func update_money_for_clients(exported_dictionary):
	player_money = exported_dictionary
